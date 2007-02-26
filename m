From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC] div64_64 support
Date: Mon, 26 Feb 2007 13:28:34 -0800
Message-ID: <20070226132834.70514f19@freekitty>
References: <20070223170527.4ca695b2@freekitty>
	<Pine.LNX.4.61.0702262108010.23355@yvahk01.tjqt.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@linux01.gwdg.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:34855 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030528AbXBZV2k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Feb 2007 16:28:40 -0500
In-Reply-To: <Pine.LNX.4.61.0702262108010.23355@yvahk01.tjqt.qr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 26 Feb 2007 21:09:26 +0100 (MET)
Jan Engelhardt <jengelh@linux01.gwdg.de> wrote:

> 
> On Feb 23 2007 17:05, Stephen Hemminger wrote:
> >
> >Since there already two users of full 64 bit division in the kernel,
> >and other places maybe hiding out as well. Add a full 64/64 bit divide.
> >
> >Yes this expensive, but there are places where it is necessary.
> >It is not clear if doing the scaling buys any advantage on 64 bit platforms,
> >so for them a full divide is done.
> >
> >---
> > include/asm-arm/div64.h      |    2 ++
> > include/asm-generic/div64.h  |    8 ++++++++
> > include/asm-m68k/div64.h     |    2 ++
> > include/asm-mips/div64.h     |    8 ++++++++
> > include/asm-um/div64.h       |    1 +
> > include/asm-xtensa/div64.h   |    1 +
> > lib/div64.c                  |   22 ++++++++++++++++++++++
> > net/ipv4/tcp_cubic.c         |   22 ----------------------
> > net/netfilter/xt_connbytes.c |   16 ----------------
> > 9 files changed, 44 insertions(+), 38 deletions(-)
> 
> Actually, there is udivdi3 support in the kernel
> 
> ./arch/arm26/lib/udivdi3.c
> ./arch/sh/lib/udivdi3.c
> ./arch/sparc/lib/udivdi3.S
> 
> should not this be consolidated too?


Hmm. Those are the GCC internal versions, that are picked up but
doing divide in place. Do we want to allow general 64 bit in kernel to
be easily used? It could cause sloppy slow code, but it would look
cleaner.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
