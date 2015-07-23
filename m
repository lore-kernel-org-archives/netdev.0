From: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
Subject: Re: Several races in "usbnet" module (kernel 4.1.x)
Date: Thu, 23 Jul 2015 11:43:14 +0200
Message-ID: <1437644594.4377.12.camel@suse.com>
References: <55AD3A41.2040100@rosalab.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Eugene Shatokhin <eugene.shatokhin-irhHPgl+04UvJsYlp49lxw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <55AD3A41.2040100-irhHPgl+04UvJsYlp49lxw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-07-20 at 21:13 +0300, Eugene Shatokhin wrote:
> [Race #5]
> 
> Race on dev->rx_urb_size. I reproduced it a similar way as the races
> #2 
> and #3 (changing MTU while downloading files).
> 
> dev->rx_urb_size is written to here:
> #0  usbnet_change_mtu (usbnet.c:392)
>         dev->rx_urb_size = dev->hard_mtu;
> 
> Here is the conflicting read from dev->rx_urb_size:
> * rx_submit (usbnet.c:467)
>         size_t                  size = dev->rx_urb_size;

Yes, but what is the actual bad race? I mean, if you change
the MTU in operation, there will be a race. That is just
unavoidable.
Do we generate errors?

	Regards
		Oliver


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
