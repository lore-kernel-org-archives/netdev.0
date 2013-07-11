From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 42/50] media: usb: tlg2300: spin_lock in complete() cleanup
Date: Thu, 11 Jul 2013 17:13:33 +0400
Message-ID: <51DEAF7D.4010609@cogentembedded.com>
References: <1373533573-12272-1-git-send-email-ming.lei@canonical.com> <1373533573-12272-43-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	linux-input@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-media@vger.kernel.org, alsa-devel@alsa-project.org,
	Mauro Carvalho Chehab <mchehab@redhat.com>
To: Ming Lei <ming.lei@canonical.com>
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <1373533573-12272-43-git-send-email-ming.lei@canonical.com>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11-07-2013 13:06, Ming Lei wrote:

     Subject doesn't match the patch.

> Complete() will be run with interrupt enabled, so disable local
> interrupt before holding a global lock which is held without
> irqsave.
>
> Cc: Mauro Carvalho Chehab <mchehab@redhat.com>
> Cc: linux-media@vger.kernel.org
> Signed-off-by: Ming Lei <ming.lei@canonical.com>
> ---
>   drivers/media/usb/tlg2300/pd-alsa.c |    3 +++
>   1 file changed, 3 insertions(+)

> diff --git a/drivers/media/usb/tlg2300/pd-alsa.c b/drivers/media/usb/tlg2300/pd-alsa.c
> index 3f3e141..cbccc96 100644
> --- a/drivers/media/usb/tlg2300/pd-alsa.c
> +++ b/drivers/media/usb/tlg2300/pd-alsa.c
[...]
> @@ -156,6 +157,7 @@ static inline void handle_audio_data(struct urb *urb, int *period_elapsed)
>   		memcpy(runtime->dma_area + oldptr * stride, cp, len * stride);
>
>   	/* update the statas */
> +	local_irq_save(flags);
>   	snd_pcm_stream_lock(pa->capture_pcm_substream);
>   	pa->rcv_position	+= len;
>   	if (pa->rcv_position >= runtime->buffer_size)
> @@ -167,6 +169,7 @@ static inline void handle_audio_data(struct urb *urb, int *period_elapsed)
>   		*period_elapsed = 1;
>   	}
>   	snd_pcm_stream_unlock(pa->capture_pcm_substream);
> +	local_irq_restore(flags);
>   }

WBR, Sergei


