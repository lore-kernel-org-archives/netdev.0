From: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: Many USB ethernet devices are broken over xhci
Date: Wed, 29 Jan 2014 14:26:15 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D46742C@AcuExch.aculab.com>
References: <063D6719AE5E284EB5DD2968C1650D6D46624F@AcuExch.aculab.com>
 <20140127233326.GB652@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
To: 'Greg KH' <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140127233326.GB652-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Content-Language: en-US
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Greg KH 
> On Mon, Jan 27, 2014 at 04:06:22PM +0000, David Laight wrote:
> > Many of the net/usb ethernet drivers (including common ones like
> > the smsc95xx) will fail to transmit all packet length properly
> > when connected to a USB3 port (ie using the xhci driver).
> 
> That's odd, as I've never had a problem with my USB 3.0 ethernet device
> (sorry, don't remember what driver it uses), and I stress it all the
> time.

If it is the ax88179_178a driver then it carefully pads packets
that are multiples of the message size.

> I've also run two different USB 2 ethernet devices on xhci with no
> issues at all, so perhaps the "many" statement might not be true?

Dunno, quite a few will send down requests with URB_SEND_SERO set.
Whether this causes a problem depends on exactly how the ethernet
packets are encapsulated in usb ones.
The ax88179_178a hardware gets very confused if you fail to send
a ZLP - which it why it uses the 'bodge' in usbnet to append a byte.

> > The underlying problem is that they assume the host controller
> > will honour the URB_ZERO_PACKET flag - which usbnet sets because
> > they specify FLAG_SEND_ZLP.
> >
> > However no one has ever added support for URB_ZERO_PACKET to
> > the xhci driver - so packets that need padding (probably 512
> > bytes after any header is added) will not be sent correctly
> > and may have very adverse effects on the usb target.
> 
> Really?  How has things been working so well up to now without this
> support?  Doesn't the hardware automatically add this padding with no
> explicit need for the xhci driver to do something?

Nope - things must work by luck!
Try ping -n $((512-0x32)) on an smsc95xx card - it should need a ZLP.

> > I don't think anything significant has changed (in the main kernel
> > sources) since I wrote the patch.
> 
> Then resubmit it, don't post links to it on the web, there's nothing we
> can do with them, sorry.

I've resubmitted it as a v3 patch (to linux-usb) in small steps so that
the changes are easier to verify.
The final result is slightly different as I spotted a couple of minor
issues when re-reading the final version.
Mostly due to another 2 months of looking at this code.

	David




--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
