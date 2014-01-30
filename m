From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH RFC 1/1] usb: Tell xhci when usb data might be misaligned
Date: Thu, 30 Jan 2014 22:50:21 +0100
Message-ID: <87iot1qgv6.fsf@nemi.mork.no>
References: <20140130211816.GB3787@xanatos>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>,
	"linux-usb\@vger.kernel.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev\@vger.kernel.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Nyman\, Mathias" <mathias.nyman-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Mark Lord <mlord-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Freddy Xin <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
To: Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140130211816.GB3787@xanatos> (Sarah Sharp's message of "Thu,
	30 Jan 2014 13:18:16 -0800")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46WIW, the plan looks fine to me.  Just adding a couple of hints to
simplify the implementation.

Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org> writes:

> Let's do this fix the right way, instead of wall papering over the
> issue.  Here's what we should do:
>
> 1. Disable scatter-gather for the ax88179_178a driver when it's under=
 an
>    xHCI host.

No need to make this conditional.  SG is only enabled in the
ax88179_178a driver if udev->bus->no_sg_constraint is true, so it
applies only to xHCI hosts in the first place.

> 2. Revert the following commits:
>    f2d9b991c549 xhci: Set scatter-gather limit to avoid failed block =
writes.
>    d6c9ea9069af xhci: Avoid infinite loop when sg urb requires too ma=
ny trbs
>    35773dac5f86 usb: xhci: Link TRB must not occur within a USB paylo=
ad burst
>
> 3. Dan and Mathias can work together to come up with an overall plan =
to
>    change the xHCI driver architecture to be fully compliant with the=
 TD
>    fragment rules.  That can be done over the next few kernel release=
s.
>
> The end result is that we don't destabilize storage or break userspac=
e
> USB drivers, we don't break people's xHCI host controllers,
> the ax88179_178a USB ethernet devices still work under xHCI (a bit wi=
th
> worse performance), and other USB ethernet devices still get the
> performance improvement introduced in 3.12.

No other usbnet drivers has enabled SG...  Which is why you have only
seen this problem with the ax88179_178a devices.  So there is no
performance improvement to keep.



Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
