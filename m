From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: [patch v2] net/usb: remove err() messages in few drivers
Date: Wed, 14 Jan 2009 09:09:43 +0100
Message-ID: <200901140909.44982.oliver@neukum.org>
References: <1231805322.12962.4.camel@tux.localhost> <200901131207.03724.oliver@neukum.org> <208cbae30901131622heccfee6uf312022ba1d4fb28@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David Brownell" <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	"Greg KH" <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Alexey Klimov" <klimov.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <208cbae30901131622heccfee6uf312022ba1d4fb28-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Wednesday 14 January 2009 01:22:26 schrieb Alexey Klimov:
> > Use the interface passed into probe(): =A0dev_err(&intf->dev, ...) =
etc

A USB driver is fundamentally a driver for a device's interfaces.
Therefore the interface's device struct is the obviously correct choice=
=2E

> Well, in few v4l-dvb drivers successfully used &radio->usbdev->dev in
> debug messages and that doesn't look wrong.

That will not allow you to identify which interface caused the message.
=20
> Hmm, i see that struct usb_interface passed to probe function for
> example, and here in catc_irq_done struct urb passed, and then we hav=
e
> struct catc. So, messages based on catc->usbdev->dev. I can switch to
> &catc->netdev->dev when it's safe to do, right?

You cannot. The point of passing a device pointer is to identify the de=
vice.
The device in the network view and the USB view is not identical. You
have to pick one choice and stick with it and if for some reason that i=
s not
possible you cannot use this debugging functions.

	Regards
		Oliver
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
