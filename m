From: David Miller <davem@davemloft.net>
Subject: Re: smc91x: commit 51ac3beffd4afaea4350526cf01fe74aaff25eff breaks
 compilation
Date: Mon, 03 Nov 2008 00:05:58 -0800 (PST)
Message-ID: <20081103.000558.90080007.davem@davemloft.net>
References: <20081103071720.GB18153@roarinelk.homelinux.net>
	<1aad82fa0811022330u3864f12che3f903a43402e043@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mano@roarinelk.homelinux.net, netdev@vger.kernel.org
To: vapier@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53019
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754830AbYKCIGX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 03:06:23 -0500
In-Reply-To: <1aad82fa0811022330u3864f12che3f903a43402e043@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Mike Frysinger" <vapier@gentoo.org>
Date: Mon, 3 Nov 2008 02:30:01 -0500

> On Mon, Nov 3, 2008 at 2:17 AM, Manuel Lauss wrote:
> > (Resend with correct netdev addr)
> >
> > Hi Mike,
> >
> > your commit 51ac3beffd4afaea4350526cf01fe74aaff25eff  causes this
> > compile failure on my SH and MIPS testboards (2.6.28-rc3):
> >
> >  CC      drivers/net/smc91x.o
> > /mnt/work/sh7760/kernel/linux-2.6.git/drivers/net/smc91x.c: In function 'smc_request_attrib':
> > /mnt/work/sh7760/kernel/linux-2.6.git/drivers/net/smc91x.c:2067: error: 'lp' undeclared (first use in this function)
> > /mnt/work/sh7760/kernel/linux-2.6.git/drivers/net/smc91x.c:2067: error: (Each undeclared identifier is reported only once
> > /mnt/work/sh7760/kernel/linux-2.6.git/drivers/net/smc91x.c:2067: error: for each function it appears in.)
> > /mnt/work/sh7760/kernel/linux-2.6.git/drivers/net/smc91x.c: In function 'smc_release_attrib':
> > /mnt/work/sh7760/kernel/linux-2.6.git/drivers/net/smc91x.c:2079: error: 'lp' undeclared (first use in this function)
> > make[2]: *** [drivers/net/smc91x.o] Error 1
> > make[1]: *** [drivers/net/smc91x.o] Error 2
> >
> > Reverting this commit fixes it.
> 
> are you using modifiied sources or something ? there's clearly no lp
> reference in mainline:

Mike, read the damn code!

ATTRIB_SIZE uses SMC_IO_SHIFT, which in some configurations
evaluates to 'lp->io_shift'.

See my other reply with the fix patch.
