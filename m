From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [PATCH] s2io ppc64 fix for readq/writeq
Date: Mon, 6 Nov 2006 21:57:08 -0500
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD77E2956F@nekter>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Benjamin Herrenschmidt" <benh@kernel.crashing.org>,
	"Jeff Garzik" <jgarzik@pobox.com>,
	"Linus Torvalds" <torvalds@osdl.org>, <netdev@vger.kernel.org>,
	<rolandd@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:9859 "EHLO
	barracuda.s2io.com") by vger.kernel.org with ESMTP id S1750953AbWKGDA2 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Nov 2006 22:00:28 -0500
Received: from owa.neterion.com (unknown [72.1.205.142])
	by barracuda.s2io.com (Spam Firewall) with ESMTP id 5BB062004B3B
	for <netdev@vger.kernel.org>; Mon,  6 Nov 2006 22:00:27 -0500 (EST)
Content-class: urn:content-classes:message
To: "Roland Dreier" <rdreier@cisco.com>,
	"Christoph Hellwig" <hch@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Roland Dreier [mailto:rdreier@cisco.com]
> Sent: Monday, November 06, 2006 12:55 PM
> To: Christoph Hellwig
> Cc: Ramkrishna Vepa; Benjamin Herrenschmidt; Jeff Garzik; Linus
Torvalds;
> netdev@vger.kernel.org; rolandd@cisco.com
> Subject: Re: [PATCH] s2io ppc64 fix for readq/writeq
> 
>  > For consistencies sake we really want to have readq() and writeq()
> available
>  > on all platforms.  I remember that some IB cards require it to
actually
>  > be a 64bit transactions, otherwise they have to do funny
workarounds.
>  > I think the best solution is to define ARCH_HAS_ATOMIC_READQ_WRITEQ
>  > and let drivers do their workarounds based on that.
>  >
>  > I've Cc'ed Roland because he should be able to explain the IB issue
in
>  > details.
> 
> The issue I know about is drivers/infiniband/hw/mthca.  The card has
> 64-bit "doorbell registers", and the restriction is that if you write
> the doorbell write two 32-bit writes, you can't write anything else on
> the same register page in between writing the two halves.  Since
> different CPUs might be doing stuff on the same doorbell page at the
> same time, there are two things we can do:
>  - If writeq() exists then use that and assume it will generate only a
>    single bus transaction that can't let anything sneak in the
>    middle.  (That's a fairly safe assumption because the devices being
>    driven are either 64-bit PCI-X or PCIe only)
>  - If writeq() doesn't exist, use a spinlock to protect access to each
>    doorbell page.
> 
> ARCH_HAS_ATOMIC_READQ_WRITEQ would be fine for that, but of course the
> tricky thing is writing down the exact semantics that "HAS_ATOMIC" is
> actually promising.
> 
>  - R.
[Ram] If the writes broken up into 32 bit writes they are posted to the
bridge and need to be flushed with a lock around the whole access. This
is in the domain of the driver and need not be part of the platform
specific code. 

Ram

