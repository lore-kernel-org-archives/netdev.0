From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] Intel IXP4xx network drivers v.2 - Ethernet and HSS
Date: Wed, 16 May 2007 11:41:00 +0200
Message-ID: <20070516094100.GB16262@xi.wantstofly.org>
References: <464034CF.20700@wpkg.org> <20070516071300.GB14222@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Christoph Hellwig <hch@infradead.org>,
	Tomasz Chmielewski <mangoo@wpkg.org>,
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	Michael Jones <mlj28@cam.ac.uk>,
	Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:33465 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753981AbXEPJlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2007 05:41:07 -0400
Content-Disposition: inline
In-Reply-To: <20070516071300.GB14222@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 16, 2007 at 08:13:01AM +0100, Christoph Hellwig wrote:

> > >>+#ifndef __ARMEB__
> > >>+#warning Little endian mode not supported
> > >>+#endif
> > >
> > >Personally I'm less fussed about WAN / LE support. Anyone with any  
> > >sense will run ixp4xx boards doing such a specialised network  
> > >operation as BE. Also, NSLU2-Linux can't test this functionality with  
> > >our LE setup as we don't have this hardware on-board. You may just  
> > >want to declare a depends on ARMEB in Kconfig (with or without OR  
> > >(ARM || BROKEN) ) and have done with it - it's up to you.
> > 
> > Christian Hohnstaedt's work did support LE though.
> > 
> > Not all ixp4xx boards are by definition "doing such a specialised 
> > network operation".
> > 
> > Krzysztof, why is LE not supported?
> > 
> > Do you need access to ixp4xx that starts in LE mode?
> 
> Not even trying to support LE is a clear merge blocker.  Maybe
> Krzysztof can't actually test it himself, which is fine - but
> not even pretending to be endian clean is not what proper Linux
> drivers do.

The issue is not that the driver is not 'endian clean'.

This is a driver for an on-chip ethernet MAC on an ARM CPU.  I.e. the
ethernet MAC is on the CPU itself, it's not some kind of PCI device or
something like that.  The ARM CPU in question can be run in either
little endian or big endian mode.  Making a driver work in both modes
of operation is generally not just an issue of adding a couple of
be32_to_cpu()s in the right places.

For example, intel IXP2000 and IXP23xx CPU support in arch/arm only
supports big-endian mode of operation, and none of the associated
drivers support little-endian mode.

Most of the other CPU support in arch/arm only supports
little-endian mode, and none of the associated drivers support
big-endian mode.  According to your criterion, that would mean that
most of the ARM drivers (alsa, usb, framebuffer, networking, etc.)
should never have been accepted in the kernel tree in the first place.
