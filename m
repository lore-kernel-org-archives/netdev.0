From: Daniel Mack <zonque@gmail.com>
Subject: Re: [PATCH 44/50] sound: usb: caiaq: spin_lock in complete() cleanup
Date: Thu, 11 Jul 2013 16:06:45 +0200
Message-ID: <51DEBBF5.7090909@gmail.com>
References: <1373533573-12272-1-git-send-email-ming.lei@canonical.com> <1373533573-12272-45-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	linux-input@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-media@vger.kernel.org, alsa-devel@alsa-project.org,
	Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.de>
To: Ming Lei <ming.lei@canonical.com>
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <1373533573-12272-45-git-send-email-ming.lei@canonical.com>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11.07.2013 11:06, Ming Lei wrote:
> Complete() will be run with interrupt enabled, so change to
> spin_lock_irqsave().
> 
> Cc: Daniel Mack <zonque@gmail.com>
> Cc: Jaroslav Kysela <perex@perex.cz>
> Cc: Takashi Iwai <tiwai@suse.de>
> Cc: alsa-devel@alsa-project.org
> Signed-off-by: Ming Lei <ming.lei@canonical.com>

Sound right to me, thanks.

Acked-by: Daniel Mack <zonque@gmail.com>



> ---
>  sound/usb/caiaq/audio.c |    5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/sound/usb/caiaq/audio.c b/sound/usb/caiaq/audio.c
> index 7103b09..e5675ab 100644
> --- a/sound/usb/caiaq/audio.c
> +++ b/sound/usb/caiaq/audio.c
> @@ -672,10 +672,11 @@ static void read_completed(struct urb *urb)
>  		offset += len;
>  
>  		if (len > 0) {
> -			spin_lock(&cdev->spinlock);
> +			unsigned long flags;
> +			spin_lock_irqsave(&cdev->spinlock, flags);
>  			fill_out_urb(cdev, out, &out->iso_frame_desc[outframe]);
>  			read_in_urb(cdev, urb, &urb->iso_frame_desc[frame]);
> -			spin_unlock(&cdev->spinlock);
> +			spin_unlock_irqrestore(&cdev->spinlock, flags);
>  			check_for_elapsed_periods(cdev, cdev->sub_playback);
>  			check_for_elapsed_periods(cdev, cdev->sub_capture);
>  			send_it = 1;
> 

