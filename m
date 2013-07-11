From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 05/50] USB: misc: uss720: spin_lock in complete() cleanup
Date: Thu, 11 Jul 2013 16:15:22 +0400
Message-ID: <51DEA1DA.5060706@cogentembedded.com>
References: <1373533573-12272-1-git-send-email-ming.lei@canonical.com> <1373533573-12272-6-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	linux-input-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org
To: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1373533573-12272-6-git-send-email-ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On 11-07-2013 13:05, Ming Lei wrote:

> Complete() will be run with interrupt enabled, so change to
> spin_lock_irqsave().

> Signed-off-by: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> ---
>   drivers/usb/misc/uss720.c |    6 +++++-
>   1 file changed, 5 insertions(+), 1 deletion(-)

> diff --git a/drivers/usb/misc/uss720.c b/drivers/usb/misc/uss720.c
> index e129cf6..f7d15e8 100644
> --- a/drivers/usb/misc/uss720.c
> +++ b/drivers/usb/misc/uss720.c
> @@ -121,6 +121,7 @@ static void async_complete(struct urb *urb)
>   		dev_err(&urb->dev->dev, "async_complete: urb error %d\n",
>   			status);
>   	} else if (rq->dr.bRequest == 3) {
> +		unsigned long flags;

    Empty line wouldn't hurt here, after declaration.

>   		memcpy(priv->reg, rq->reg, sizeof(priv->reg));

WBR, Sergei


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
