From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: TG3 data corruption (TSO ?)
Date: Sat, 09 Sep 2006 08:49:33 +1000
Message-ID: <1157755773.31071.118.camel@localhost.localdomain>
References: <1551EAE59135BE47B544934E30FC4FC093FB19@NT-IRVA-0751.brcm.ad.broadcom.com>
	 <1157751689.31071.97.camel@localhost.localdomain>
	 <1157753242.9584.4.camel@rh4>
	 <1157754326.31071.115.camel@localhost.localdomain>
	 <1157755220.9584.21.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Segher Boessenkool <segher@kernel.crashing.org>,
	Linux Kernel list <linux-kernel@vger.kernel.org>,
	Paul Mackerras <paulus@samba.org>,
	Anton Blanchard <anton@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:10122 "EHLO gate.crashing.org")
	by vger.kernel.org with ESMTP id S1751150AbWIHWtu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2006 18:49:50 -0400
To: Michael Chan <mchan@broadcom.com>
In-Reply-To: <1157755220.9584.21.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> > I'd rather not have to do that, or even if I go that way, not have to
> > add that sync at all before the store and thus get back the few percent
> > of perfs lost due to those sync's on some heavy IO benchmarks.
> > 
> Another way to fix this without requiring drivers to add all kinds of
> barriers in the driver code is to add a writel_sync() variant.  So on
> powerpc, writel_sync() will have a sync before and after the write.  On
> most other architectures, writel_sync() is the same as writel() if the
> ordering is guaranteed.  We'll then convert tg3 and other drivers to use
> writel_sync() in places where they're needed.

I think the preferred approach for that sort of thing is to have writel
be the "sync" version and add special "relaxed" version. Now there have
been talks and debates about relaxed IOs but they generally map to
something different, typically IOs that are relaxed vs. DMA (PCI-X/PCIe
relaxed ordering options for example).

Adding yet another round of IO accessors sounds like a bit nasty to me,
driver writers will potentially not understand which ones to use etc...

Anyway, I think I'll let Anton and Paulus argue that one for now.

Cheers,
Ben.


