From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 08/50] USB: legousbtower: spin_lock in complete() cleanup
Date: Thu, 11 Jul 2013 16:18:17 +0400
Message-ID: <51DEA289.5050509@cogentembedded.com>
References: <1373533573-12272-1-git-send-email-ming.lei@canonical.com> <1373533573-12272-9-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	linux-input-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org,
	Juergen Stuber <starblue-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1373533573-12272-9-git-send-email-ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On 11-07-2013 13:05, Ming Lei wrote:

> Complete() will be run with interrupt enabled, so change to
> spin_lock_irqsave().

> Cc: Juergen Stuber <starblue-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
> Signed-off-by: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> ---
>   drivers/usb/misc/legousbtower.c |    5 +++--
>   1 file changed, 3 insertions(+), 2 deletions(-)

> diff --git a/drivers/usb/misc/legousbtower.c b/drivers/usb/misc/legousbtower.c
> index 8089479..4044989 100644
> --- a/drivers/usb/misc/legousbtower.c
> +++ b/drivers/usb/misc/legousbtower.c
> @@ -771,6 +771,7 @@ static void tower_interrupt_in_callback (struct urb *urb)
>   	struct lego_usb_tower *dev = urb->context;
>   	int status = urb->status;
>   	int retval;
> +	unsigned long flags;
>
>   	dbg(4, "%s: enter, status %d", __func__, status);
>
> @@ -788,7 +789,7 @@ static void tower_interrupt_in_callback (struct urb *urb)
>   	}
>
>   	if (urb->actual_length > 0) {
> -		spin_lock (&dev->read_buffer_lock);
> +		spin_lock_irqsave (&dev->read_buffer_lock, flags);
>   		if (dev->read_buffer_length + urb->actual_length < read_buffer_size) {
>   			memcpy (dev->read_buffer + dev->read_buffer_length,
>   				dev->interrupt_in_buffer,
> @@ -799,7 +800,7 @@ static void tower_interrupt_in_callback (struct urb *urb)
>   		} else {
>   			printk(KERN_WARNING "%s: read_buffer overflow, %d bytes dropped", __func__, urb->actual_length);
>   		}
> -		spin_unlock (&dev->read_buffer_lock);
> +		spin_unlock_irqrestore (&dev->read_buffer_lock, flags);
>   	}

    I don't think this patch passes checkpatch.pl.

WBR, Sergei
