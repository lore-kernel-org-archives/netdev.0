From: Peter Korsgaard <jacmet-OfajU3CKLf1/SzgSGea1oA@public.gmane.org>
Subject: Re: [PATCH 08/11] usbnet: dm9601: apply usbnet_link_change
Date: Thu, 11 Apr 2013 17:18:13 +0200
Message-ID: <87zjx5rt8q.fsf@dell.be.48ers.dk>
References: <1365691240-816-1-git-send-email-ming.lei@canonical.com>
	<1365691240-816-9-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1365691240-816-9-git-send-email-ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> (Ming
	Lei's message of "Thu, 11 Apr 2013 22:40:37 +0800")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

>>>>> "Ming" == Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> writes:

 Ming> Use usbnet_link_change to handle link change centrally.

Acked-by: Peter Korsgaard <jacmet-OfajU3CKLf1/SzgSGea1oA@public.gmane.org>

 Ming> Cc: Peter Korsgaard <jacmet-OfajU3CKLf1/SzgSGea1oA@public.gmane.org>
 Ming> Signed-off-by: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
 Ming> ---
 Ming>  drivers/net/usb/dm9601.c |    7 +------
 Ming>  1 file changed, 1 insertion(+), 6 deletions(-)

 Ming> diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
 Ming> index 174e5ec..2dbb946 100644
 Ming> --- a/drivers/net/usb/dm9601.c
 Ming> +++ b/drivers/net/usb/dm9601.c
 Ming> @@ -524,12 +524,7 @@ static void dm9601_status(struct usbnet *dev, struct urb *urb)
 
 Ming>  	link = !!(buf[0] & 0x40);
 Ming>  	if (netif_carrier_ok(dev->net) != link) {
 Ming> -		if (link) {
 Ming> -			netif_carrier_on(dev->net);
 Ming> -			usbnet_defer_kevent (dev, EVENT_LINK_RESET);
 Ming> -		}
 Ming> -		else
 Ming> -			netif_carrier_off(dev->net);
 Ming> +		usbnet_link_change(dev, link, 1);
 Ming>  		netdev_dbg(dev->net, "Link Status is: %d\n", link);
 Ming>  	}
 Ming>  }
 Ming> -- 
 Ming> 1.7.9.5



-- 
Bye, Peter Korsgaard
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
