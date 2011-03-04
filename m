From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH resent] tcp: ioctl type SIOCOUTQNSD returns amount of data not sent
Date: Fri, 4 Mar 2011 10:57:53 +0100
Message-ID: <201103041057.53671.arnd@arndb.de>
References: <1299228497-21246-1-git-send-email-sledz@dresearch.de> <20110304.010428.71127798.davem@davemloft.net> <4D70B621.7020307@dresearch.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, m.schuknecht@dresearch.de
To: Steffen Sledz <sledz@dresearch.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D70B621.7020307@dresearch.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 04 March 2011 10:51:29 Steffen Sledz wrote:
> Am 04.03.2011 10:04, schrieb David Miller:

> > Hitting only asm-generic/ioctls.h is insufficient, many architectures do
> > not make use of this file and the build will fail for them with your patch
> > applied.
> 
> That's not fully clear to me.
> 
> We made the define similar to the existing TIOCOUTQ. What other files should be hit?
> 

These ones:

$ git grep TIOCOUTQ arch/*/include/
arch/alpha/include/asm/ioctls.h:#define TIOCOUTQ        _IOR('t', 115, int)     /* output queue size */
arch/mips/include/asm/ioctls.h:#define TIOCOUTQ 0x7472          /* output queue size */
arch/parisc/include/asm/ioctls.h:#define TIOCOUTQ       0x5411
arch/powerpc/include/asm/ioctls.h:#define TIOCOUTQ        _IOR('t', 115, int)     /* output queue size */
arch/sh/include/asm/ioctls.h:#define TIOCOUTQ        _IOR('t', 115, int)     /* output queue size */
arch/sparc/include/asm/ioctls.h:#define TIOCOUTQ        _IOR('t', 115, int)
arch/xtensa/include/asm/ioctls.h:#define TIOCOUTQ        _IOR('t', 115, int)     /* output queue size */

	Arnd
