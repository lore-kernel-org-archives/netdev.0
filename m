From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 2/2] myri10ge: use ioremap_wc
Date: Mon, 11 Aug 2008 10:09:25 +0100
Message-ID: <20080811090925.GA29143@flint.arm.linux.org.uk>
References: <488447E7.2060505@myri.com> <48844831.9040102@myri.com> <20080810112500.GA8060@deprecation.cyrius.com> <489ED823.6000005@myri.com> <20080810123844.GG2486@deprecation.cyrius.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brice Goglin <brice@myri.com>, Jeff Garzik <jeff@garzik.org>,
	netdev@vger.kernel.org
To: Martin Michlmayr <tbm@cyrius.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:57095 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751071AbYHKJKn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 05:10:43 -0400
Content-Disposition: inline
In-Reply-To: <20080810123844.GG2486@deprecation.cyrius.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 10, 2008 at 03:38:44PM +0300, Martin Michlmayr wrote:
> * Brice Goglin <brice@myri.com> [2008-08-10 13:59]:
> > > This change leads to a compilation failure on (at least) arm:
> > >
> > >   CC [M]  drivers/net/myri10ge/myri10ge.o
> > > drivers/net/myri10ge/myri10ge.c: In function ???myri10ge_probe???:
> > > drivers/net/myri10ge/myri10ge.c:3725: error: implicit declaration of function ???ioremap_wc???
> > > drivers/net/myri10ge/myri10ge.c:3725: warning: assignment makes pointer from integer without a cast
> > > make[3]: *** [drivers/net/myri10ge/myri10ge.o] Error 1
> > 
> > Isn't arm's asm/io.h supposed to get
> > #ifndef ARCH_HAS_IOREMAP_WC
> > #define ioremap_wc ioremap_nocache
> > #endif
> > from asm-generic/iomap.h since ARCH_HAS_IOREMAP_WC isn't defined on arm ?
> 
> arch/arm/include/asm/io.h doesn't include asm-generic/iomap.h.  When I
> add this includes, myri10ge compiles.
> 
> Russell, any comments on the change below?

Only that I'm not including asm-generic/iomap.h - we have our own
iomap implementation, and the generic stuff in there isn't applicable
to ARM.

I believe Lennert is sorting out ioremap_wc().
