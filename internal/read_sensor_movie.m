function [sensor_movie, num_frames_total]=read_sensor_movie(LFM_folder,x_offset,y_offset,dx,Nnum,rect,frames, mask)
if nargin < 8
    mask = true;
end

%%
p.rect_dir = LFM_folder;
if exist(p.rect_dir, 'dir')
    infiles_struct = dir(fullfile(p.rect_dir, '/*.tif*'));
    [~, order] = sort({infiles_struct(:).name});
    infiles_struct = infiles_struct(order);
else
    infiles_struct = dir(fullfile(p.rect_dir));
    [p.rect_dir, ~, ~] = fileparts(p.rect_dir);
    disp('LFM_folder does not exist');
end

%%
if nargin<7 || isempty(frames)
    frames.start=1;
    frames.step=1;
    frames.end=size(infiles_struct,1);
    frames.mean=0;
end
frames.end=min(frames.end,size(infiles_struct,1));
num_frames_total=size(infiles_struct,1);

if frames.mean
    for ig=1:length(frames.start:frames.step:frames.end)
        for ig_ = 1 : min(frames.step, frames.end-(ig-1)*frames.step)
            img_ix=(ig-1)*frames.step + ig_;
            if rect==1
                img_rect =  ImageRect(double(imread(fullfile(p.rect_dir, infiles_struct(img_ix).name), 'tiff')), x_offset, y_offset, dx, Nnum,0);
            else
                img_rect = single(imread(fullfile(p.rect_dir, infiles_struct(img_ix).name), 'tiff'));
            end
            if img_ix == 1
                sens = ones(numel(img_rect), size(1:frames.step:frames.end,2), 'single');
            end
            if size(infiles_struct)==1
                sens = img_rect(:);
            else
                sens(:, ig_) = img_rect(:);
            end
        end
        if mod(ig, 20) == 1
            fprintf([num2str(ig) ' ']);       
        end
        sensor_movie(:,ig)=mean(sens,2);
    end
else
    infiles_struct = infiles_struct(frames.start:frames.step:frames.end);
    for img_ix = 1:size(infiles_struct,1)
        if mod(img_ix, 20) == 1
            fprintf([num2str(img_ix) ' ']);
        end
        if rect==1
            img_rect = ImageRect(double(imread(fullfile(p.rect_dir, infiles_struct(img_ix).name), 'tiff')) .* mask, x_offset, y_offset, dx, Nnum, 0);
        else
            img_rect = single(imread(fullfile(p.rect_dir, infiles_struct(img_ix).name), 'tiff')) .* mask;
        end
        if img_ix == 1
            %         sensor_movie = ones(size(img_rect, 1), size(img_rect, 2), size(infiles_struct,1), 'double');
            sensor_movie = ones(numel(img_rect), size(infiles_struct,1), 'single');
        end
        if size(infiles_struct)==1
            %         sensor_movie(:, :) = img_rect;
            sensor_movie= img_rect(:);
        else
            %         sensor_movie(:, :, img_ix) = img_rect;
            sensor_movie(:, img_ix) = img_rect(:);
        end
    end
end
fprintf('\n');
end
