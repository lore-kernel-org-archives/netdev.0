From: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
Subject: Re: [PATCH] cdc_ncm: do not call usbnet_link_change from
 cdc_ncm_bind
Date: Tue, 08 Mar 2016 21:12:29 +0100
Message-ID: <1457467949.19125.5.camel@suse.com>
References: <CA+55aFw43uKkUK-h=VMwXcb9NM+g2AdeB960kWb4YihmjQ8DRw@mail.gmail.com>
	 <20160307.141100.1511700720120062677.davem@davemloft.net>
	 <CA+fCnZdurxGBsOrANb_m5BLK1BKzH3J_GmZ=dbH=ABThgFNGxg@mail.gmail.com>
	 <20160307.145406.188091362181073486.davem@davemloft.net>
	 <87k2le815w.fsf_-_@nemi.mork.no>
	 <CA+55aFxt7zWW+-EkwCbAWCb9wkgVswYJNAz86bc_QRcv1pBHZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: bjorn-yOkvZcmFvRU@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Andrey Konovalov <andreyknvl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Alexander Potapenko <glider-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Kostya Serebryany <kcc-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	USB list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA+55aFxt7zWW+-EkwCbAWCb9wkgVswYJNAz86bc_QRcv1pBHZw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-03-08 at 11:43 -0800, Linus Torvalds wrote:
> Why is that FLAG_LINK_INTR thing not just always used?
> 
> The _only_ thing that FLAG_LINK_INTR does is to cause
> 
>         usbnet_link_change(dev, 0, 0);
> 
> to be called after network device attach. That doesn't seem to be
> controversial.

It depends on the devices' capabilities.
For a few old devices that would be deadly, because they cannot
indicate that a link goes up again.

> Looking at some examples, we have ax88179_178a.c that doesn't set the
> flag, but instead does that usbnet_link_change() call at the end of
> ax88179_bind().
> 
> There are a few drivers that seem to never call that
> usbnet_link_change() at all, and don't have that FLAG_LINK_INTR flag.
> Would they break?

Yes. If we did the call unconditionally. We could not do it,
then we'd see some spurious detection of interfaces being up,
but something breaks. Today I'd probably require a flag
for those cases that do not want the call to be made, but the
distinction as such is necessary.

	Regards
		Oliver



--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
