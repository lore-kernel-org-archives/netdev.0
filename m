From: Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [PATCH RFC 1/1] usb: Tell xhci when usb data might be misaligned
Date: Mon, 3 Feb 2014 09:55:00 -0800
Message-ID: <20140203175500.GA26115@xanatos>
References: <20140130211816.GB3787@xanatos>
 <87iot1qgv6.fsf@nemi.mork.no>
 <20140130221511.GD14228@xanatos>
 <CACVXFVMVoMAH3DRiv-VYZL8VWq2Rw+fZwreVtUVm1M44HR+X8Q@mail.gmail.com>
 <20140131190035.GB18262@xanatos>
 <CACVXFVN3OsPM5CBWjc4kh_sGo3fMwpvBoYer7VtreUWrvWA=+Q@mail.gmail.com>
 <52ECF6F5.6060207@pobox.com>
 <CACVXFVOynsojKo+aukHY4q+MkEyhHXC0=OpN0ysu0TGuUjY8sA@mail.gmail.com>
 <52ED5381.2010106@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	=?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn-yOkvZcmFvRU@public.gmane.org>,
	David Laight <David.Laight-JxhZ9S5GRejQT0dZR+AlfA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Nyman, Mathias" <mathias.nyman-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Freddy Xin <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
To: Mark Lord <mlord-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <52ED5381.2010106-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Feb 01, 2014 at 03:05:21PM -0500, Mark Lord wrote:
> On 14-02-01 09:18 AM, Ming Lei wrote:
> >
> > Even real regressions are easily/often introduced, and we are discussing
> > how to fix that. I suggest to unset the flag only for the known buggy
> > controllers.

Ming, the regression cannot be easily fixed in this case.  We tried the
"easy, quick fix" and it broke USB storage and usbfs.  The patches to
paper over those issues started to creep into the upper layers, and I'm
not willing to add more code to hack around the issues caused by the
"quick fix".  We need to do this right, not wall-paper over the issues.

> It is not the controllers that are particularly "buggy" here.
> But rather the drivers and design of parts of the kernel.

As Mark mentioned, the host controllers aren't buggy.  The xHCI driver
simply doesn't handle a 1.0 host controller requirement, TD fragments,
very well.  Only the USB ethernet layer triggers this bug, because the
USB storage layer hands down scatter-gather lists in multiples of the
max packet size.

You tested on a 1.0 host controller, and it apparently didn't need the
TD fragments requirement.  It seems that Intel 1.0 xHCI host controllers
do need that requirement.  Perhaps we can add an xHCI driver quirk for
an exception so that your host can allow any kind of scatter-gather?

Sarah Sharp
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
