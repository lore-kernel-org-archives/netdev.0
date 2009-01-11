From: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
Subject: Re: [patch review 1/3] net/usb: catc.c - place dev_err instead of err()
Date: Sun, 11 Jan 2009 13:48:37 -0800
Message-ID: <200901111348.37993.david-b@pacbell.net>
References: <1231690591.2050.103.camel@tux.localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexey Klimov <klimov.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1231690591.2050.103.camel-XMdqyYT0w3Zyw3qLyVIJKA@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sunday 11 January 2009, Alexey Klimov wrote:
> -=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0err("submit(rx_urb) status %d", res);
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0dev_err(&urb->dev->dev, "submit(rx_urb) status =
%d\n", res);

You should really find and use the device on the *interface* to which
that driver is bound, rather than the one in the URB.  That's what
gets passed in to probe(); drivers normally remember that until a
remove() callback unbinds the driver from that interface.

A weak analogy is issuing a diagnostic about the PCI bus to which
the PCI device is attached, instead of the PCI device itself.  In
both cases, the diagnostic would point to the wrong thing...

The other two patches got this right in at least some cases, but I
didn't look in any detail.

- Dave

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
