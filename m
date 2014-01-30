From: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Subject: Re: [PATCH RFC 1/1] usb: Tell xhci when usb data might be misaligned
Date: Thu, 30 Jan 2014 14:15:11 -0800
Message-ID: <20140130221511.GD14228@xanatos>
References: <20140130211816.GB3787@xanatos>
 <87iot1qgv6.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Laight <David.Laight@ACULAB.COM>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>,
	Dan Williams <dan.j.williams@intel.com>,
	"Nyman, Mathias" <mathias.nyman@intel.com>,
	Mark Lord <mlord@pobox.com>,
	Alan Stern <stern@rowland.harvard.edu>,
	Freddy Xin <freddy@asix.com.tw>,
	Ming Lei <ming.lei@canonical.com>
To: =?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:61628 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753108AbaA3WPR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jan 2014 17:15:17 -0500
Content-Disposition: inline
In-Reply-To: <87iot1qgv6.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 30, 2014 at 10:50:21PM +0100, Bj=F8rn Mork wrote:
> FWIW, the plan looks fine to me.  Just adding a couple of hints to
> simplify the implementation.
>=20
> Sarah Sharp <sarah.a.sharp@linux.intel.com> writes:
>=20
> > Let's do this fix the right way, instead of wall papering over the
> > issue.  Here's what we should do:
> >
> > 1. Disable scatter-gather for the ax88179_178a driver when it's und=
er an
> >    xHCI host.
>=20
> No need to make this conditional.  SG is only enabled in the
> ax88179_178a driver if udev->bus->no_sg_constraint is true, so it
> applies only to xHCI hosts in the first place.

Ah, so you're suggesting just reverting commit
3804fad45411b48233b48003e33a78f290d227c8 "USBNET: ax88179_178a: enable
tso if usb host supports sg dma"?

> > 2. Revert the following commits:
> >    f2d9b991c549 xhci: Set scatter-gather limit to avoid failed bloc=
k writes.
> >    d6c9ea9069af xhci: Avoid infinite loop when sg urb requires too =
many trbs
> >    35773dac5f86 usb: xhci: Link TRB must not occur within a USB pay=
load burst
> >
> > 3. Dan and Mathias can work together to come up with an overall pla=
n to
> >    change the xHCI driver architecture to be fully compliant with t=
he TD
> >    fragment rules.  That can be done over the next few kernel relea=
ses.
> >
> > The end result is that we don't destabilize storage or break usersp=
ace
> > USB drivers, we don't break people's xHCI host controllers,
> > the ax88179_178a USB ethernet devices still work under xHCI (a bit =
with
> > worse performance), and other USB ethernet devices still get the
> > performance improvement introduced in 3.12.
>=20
> No other usbnet drivers has enabled SG...  Which is why you have only
> seen this problem with the ax88179_178a devices.  So there is no
> performance improvement to keep.

I see.

Sarah Sharp
