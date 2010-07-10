From: Dan Carpenter <error27-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] atmel: unregister_netdev() on error
Date: Sat, 10 Jul 2010 16:12:04 +0200
Message-ID: <20100710141204.GY19184@bicker>
References: <1278767508-10164-1-git-send-email-segooon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Simon Kelley <simon-xn1N/tgparsycpQjotevgVpr/1R2p/CL@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Kulikov Vasiliy <segooon-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1278767508-10164-1-git-send-email-segooon-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 10, 2010 at 05:11:47PM +0400, Kulikov Vasiliy wrote:
> We must unregister registered device if probe_atmel_card() fails.

I think you hit send accidentally on this one?

>  	if (!probe_atmel_card(dev)) {
>  		unregister_netdev(dev);
		^^^^^^^^^^^^^^^^^^^^^^^

> -		goto err_out_res;
> +		goto err_out_unreg;
>  	}
>  
>  	netif_carrier_off(dev);
> @@ -1640,6 +1640,9 @@ struct net_device *init_atmel_card(unsigned short irq, unsigned long port,
>  
>  	return dev;
>  
> +err_out_unreg:
> +	unregister_netdev(dev);
	^^^^^^^^^^^^^^^^^^^^^^
> +

What the pants?  :P

regards,
dan carpenter

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
