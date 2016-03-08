From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH] cdc_ncm: do not call usbnet_link_change from cdc_ncm_bind
Date: Tue, 08 Mar 2016 21:18:15 +0100
Message-ID: <871t7k7mgo.fsf@nemi.mork.no>
References: <CA+55aFw43uKkUK-h=VMwXcb9NM+g2AdeB960kWb4YihmjQ8DRw@mail.gmail.com>
	<20160307.141100.1511700720120062677.davem@davemloft.net>
	<CA+fCnZdurxGBsOrANb_m5BLK1BKzH3J_GmZ=dbH=ABThgFNGxg@mail.gmail.com>
	<20160307.145406.188091362181073486.davem@davemloft.net>
	<87k2le815w.fsf_-_@nemi.mork.no>
	<CA+55aFxt7zWW+-EkwCbAWCb9wkgVswYJNAz86bc_QRcv1pBHZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Andrey Konovalov <andreyknvl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>,
	Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Alexander Potapenko <glider-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Kostya Serebryany <kcc-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	USB list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA+55aFxt7zWW+-EkwCbAWCb9wkgVswYJNAz86bc_QRcv1pBHZw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Linus Torvalds's message of "Tue, 8 Mar 2016 11:43:26 -0800")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> writes:

> So looking at this, I wonder...
>
> Why is that FLAG_LINK_INTR thing not just always used?
>
> The _only_ thing that FLAG_LINK_INTR does is to cause
>
>         usbnet_link_change(dev, 0, 0);
>
> to be called after network device attach. That doesn't seem to be con=
troversial.

Not all usbnet drivers support carrier detection, which is required to
ever bring the link up again.

> Looking at some examples, we have ax88179_178a.c that doesn't set the
> flag, but instead does that usbnet_link_change() call at the end of
> ax88179_bind().
>
> There are a few drivers that seem to never call that
> usbnet_link_change() at all, and don't have that FLAG_LINK_INTR flag.
> Would they break?

Yes.  Drivers without carrier detection will be "down" forever.

> Why is it called "FLAG_LINK_INTR" anyway? There doesn't seem to be
> anything "INTR" about it.

Beats me.  I can only say that I always find naming difficult...
We could ask Ben, who introduced it in:


commit 37e8273cd30592d3a82bcb70cbb1bdc4eaeb6b71
Author: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Date:   Wed Nov 4 15:29:52 2009 +0000

    usbnet: Set link down initially for drivers that update link state
   =20
    Some usbnet drivers update link state while others do not due to
    hardware limitations.  Add a flag to distinguish those that do, and
    set the link down initially for their devices.
   =20
    This is intended to fix this bug: http://bugs.debian.org/444043
   =20
    Signed-off-by: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>



But I guess it doesn't really matter.



Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
