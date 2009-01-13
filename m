From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH RFC v5] net: add PCINet driver
Date: Tue, 13 Jan 2009 17:33:03 +0100
Message-ID: <200901131733.04341.arnd@arndb.de>
References: <20090107195052.GA24981@ovro.caltech.edu> <200901131302.52754.rusty@rustcorp.com.au> <20090113033420.GA11065@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: Ira Snyder <iws@ovro.caltech.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.188]:52711 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752804AbZAMQdX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 11:33:23 -0500
In-Reply-To: <20090113033420.GA11065@ovro.caltech.edu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 13 January 2009, Ira Snyder wrote:
> On Tue, Jan 13, 2009 at 01:02:52PM +1030, Rusty Russell wrote:
> > 
> >    Interesting system: the guest being able to access the
> >    host's memory but not (fully) vice-versa makes this a
> >    little different from the current implementations where
> >    that was assumed.  virtio assumes that the guest will
> >    publish buffers and someone else (ie. the host) will access them.    
> 
> The guest system /could/ publish all of its RAM, but with 256MB per
> board, 19 boards per cPCI crate, that's way too much for a 32-bit PC to
> map into it's memory space. That's the real reason I use the 1MB
> windows. I could make them bigger (16MB would be fine, I think), but I
> doubt it would make much of a difference to the implementation.

The way we do it in the existing driver for cell, both sides export
just a little part of their memory to the other side, and they
also both get access to one channel of the DMA engine, which is
enough to transfer larger data sections, as the DMA engine has
access to all the memory on both sides.

	Arnd <><
