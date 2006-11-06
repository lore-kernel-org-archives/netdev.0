From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] s2io ppc64 fix for readq/writeq
Date: Mon, 6 Nov 2006 20:46:43 +0000
Message-ID: <20061106204643.GA11788@infradead.org>
References: <78C9135A3D2ECE4B8162EBDCE82CAD77E29496@nekter>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Jeff Garzik <jgarzik@pobox.com>,
	Linus Torvalds <torvalds@osdl.org>, netdev@vger.kernel.org,
	rolandd@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:11962 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1753774AbWKFUrL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Nov 2006 15:47:11 -0500
To: Ramkrishna Vepa <Ramkrishna.Vepa@neterion.com>
Content-Disposition: inline
In-Reply-To: <78C9135A3D2ECE4B8162EBDCE82CAD77E29496@nekter>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 06, 2006 at 03:33:19PM -0500, Ramkrishna Vepa wrote:
> The 64 bit io operation on the IA64 platform is a 64 bit transaction on
> the pci bus and is optimal to leave it as such. I prefer Jeff's
> suggestion  - 
> 
> guaranteeing that a "good enough for drivers" readq() and writeq() exist
> on all platforms even 32-bit platforms where the operation isn't
> inherently atomic.

For consistencies sake we really want to have readq() and writeq() available
on all platforms.  I remember that some IB cards require it to actually
be a 64bit transactions, otherwise they have to do funny workarounds.
I think the best solution is to define ARCH_HAS_ATOMIC_READQ_WRITEQ
and let drivers do their workarounds based on that.

I've Cc'ed Roland because he should be able to explain the IB issue in
details.

