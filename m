From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [PATCH] s2io ppc64 fix for readq/writeq
Date: Mon, 6 Nov 2006 15:33:19 -0500
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD77E29496@nekter>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Linus Torvalds" <torvalds@osdl.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:31466 "EHLO
	barracuda.s2io.com") by vger.kernel.org with ESMTP id S1753565AbWKFUgf convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Nov 2006 15:36:35 -0500
Received: from owa.neterion.com (unknown [72.1.205.142])
	by barracuda.s2io.com (Spam Firewall) with ESMTP id 2BCAB2004B10
	for <netdev@vger.kernel.org>; Mon,  6 Nov 2006 15:36:34 -0500 (EST)
Content-class: urn:content-classes:message
To: "Benjamin Herrenschmidt" <benh@kernel.crashing.org>,
	"Jeff Garzik" <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The 64 bit io operation on the IA64 platform is a 64 bit transaction on
the pci bus and is optimal to leave it as such. I prefer Jeff's
suggestion  - 

guaranteeing that a "good enough for drivers" readq() and writeq() exist
on all platforms even 32-bit platforms where the operation isn't
inherently atomic.

Ram

> -----Original Message-----
> From: netdev-owner@vger.kernel.org
[mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Benjamin Herrenschmidt
> Sent: Monday, November 06, 2006 1:57 AM
> To: Jeff Garzik
> Cc: Linus Torvalds; netdev@vger.kernel.org
> Subject: Re: [PATCH] s2io ppc64 fix for readq/writeq
> 
> On Mon, 2006-11-06 at 04:55 -0500, Jeff Garzik wrote:
> > Benjamin Herrenschmidt wrote:
> > > On Mon, 2006-11-06 at 01:50 -0800, Linus Torvalds wrote:
> > >> On Mon, 6 Nov 2006, Benjamin Herrenschmidt wrote:
> > >>> Anyway, what do you think of Jeff proposal to just implement
them as
> two
> > >>> 32 bits operations ? My arch guy side screams at the idea, but
if,
> > >>> indeed, drivers generally cope fine with it, I suppose that's
ok.
> > >> Last I saw, that's how normal PCI will split the IO anyway, so I
> guess it
> > >> makes sense.
> > >
> > > Hrm.. true indeed. I'll implement them that way for ppc32 then.
> >
> > Bonus points if you want to find-and-kill where individual drivers
did
> >
> > 	#ifndef readq
> > 	implement readq and writeq by hand...
> > 	#endif
> 
> Yes, well, we would have to make sure all archs have them defined
> first though, but I suppose I can have a look later this week, maybe
> tomorrow. Shouldn't be too hard :)
> 
> Ben.
> 
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

