From: Tony Lindgren <tony@atomide.com>
Subject: Re: linux-next: arm allmodconfig
Date: Wed, 29 Oct 2008 09:05:49 -0700
Message-ID: <20081029160547.GE20456@atomide.com>
References: <20081028175604.81c31cea.akpm@linux-foundation.org> <20081029094054.GA3796@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>,
	Dave Airlie <airlied@linux.ie>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Paul Moore <paul.moore@hp.com>, Takashi Iwai <tiwai@suse.de>,
	Pekka Enberg <penberg@cs.helsinki.fi>, xfs-masters@oss.sgi.com
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mho-01-bos.mailhop.org ([63.208.196.178]:61471 "EHLO
	mho-01-bos.mailhop.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753094AbYJ2QGK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 12:06:10 -0400
Content-Disposition: inline
In-Reply-To: <20081029094054.GA3796@flint.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Russell King - ARM Linux <linux@arm.linux.org.uk> [081029 02:59]:
> On Tue, Oct 28, 2008 at 05:56:04PM -0700, Andrew Morton wrote:

<snip>

> 
> > > drivers/atm/ambassador.h:257:1: warning: "FLASH_BASE" redefined
> > > In file included from arch/arm/mach-versatile/include/mach/irqs.h:22,
> > >                  from /usr/src/devel/arch/arm/include/asm/irq.h:4,
> > >                  from /usr/src/devel/arch/arm/include/asm/hardirq.h:6,
> > >                  from include/linux/hardirq.h:7,
> > >                  from include/asm-generic/local.h:5,
> > >                  from /usr/src/devel/arch/arm/include/asm/local.h:1,
> > >                  from include/linux/module.h:20,
> > >                  from drivers/atm/ambassador.c:25:
> > > arch/arm/mach-versatile/include/mach/platform.h:443:1: warning: this is the location of the previous definition
> > > In file included from drivers/atm/ambassador.c:44:
> > > drivers/atm/ambassador.h:258:1: warning: "FLASH_SIZE" redefined
> 
> Here we go again...
> 
> I do wish that people wouldn't include "platform.h" headers defining lots
> of generically named constants into a header file used by most of the
> kernel build.  It's stupid for several reasons:
> 
> 1. see the above warnings.
> 2. if you change anything in that header, you're going to get a needless
>    full kernel rebuild
> 3. and that causes additional strain on kautobuild's build caches
> 
> We've had this in the past with sa1100-regs.h and similar, and we solved
> it there.
> 
> Unfortunately, people persist in including their platform includes into
> lots of header files rather than having just the relevent C files include
> them.  Eg, arch/arm/plat-omap/include/mach/hardware.h:
> 
> /*
>  * ---------------------------------------------------------------------------
>  * Board specific defines
>  * ---------------------------------------------------------------------------
>  */
> 
> #ifdef CONFIG_MACH_OMAP_INNOVATOR
> #include "board-innovator.h"
> #endif
> 
> #ifdef CONFIG_MACH_OMAP_H2
> #include "board-h2.h"
> #endif
> ...
> #ifdef CONFIG_MACH_SX1
> #include "board-sx1.h"
> #endif
> 
> which is included via asm/io.h, asm/irq.h, asm/pci.h, asm/vga.h.
> 
> As long as this idiocracy, we're going to see these kinds of clashes.
> This stuff needs to die.  I've a good idea to do a sweep of all ARM
> includes, and commit a patch to my devel tree for linux-next to remove
> such includes as an encouragement to fixing this stuff properly.
> 
> People will then have a couple of months to sort out their mess.

I'll remove those omap includes, I have few other patches pending before
I get to that though.

Cheers,

Tony
