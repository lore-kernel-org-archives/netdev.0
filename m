From: David Miller <davem@davemloft.net>
Subject: Re: NIU driver: Sun x8 Express Quad Gigabit Ethernet Adapter (perf
 + regression IRQs)
Date: Wed, 19 Nov 2008 15:11:38 -0800 (PST)
Message-ID: <20081119.151138.93409143.davem@davemloft.net>
References: <1226572171.6834.87.camel@localhost.localdomain>
	<20081113.141513.116537651.davem@davemloft.net>
	<Pine.LNX.4.64.0811192333130.30818@ask.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jdb@comx.dk, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: hawk@diku.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46501
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753104AbYKSXLi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 18:11:38 -0500
In-Reply-To: <Pine.LNX.4.64.0811192333130.30818@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <hawk@diku.dk>
Date: Wed, 19 Nov 2008 23:58:12 +0100 (CET)

> Well that was not the real cause of the performance loss.  Because
> on kernel 2.6.27 I get really good performance (900-1200kpps)
> compared to 2.6.28 (git net-2.6).
>
> The cause of this problem (tracked down together with Robert Olsson)
> is that on 2.6.28 I have a lot less IRQs available.  It seems max 34
> IRQs.
>
> Due the reduced number of IRQs the NIU driver cannot get enough IRQs
> to the interfaces, and starts to use "IO-APIC" based IRQs.

This is almost certainly related to the driver unload bug.

I know you ran into unbuildable/unbootable kernels during a bisect,
but you really need to track down this regression.

There were a lot of IRQ changes, especially on x86.  The sequence is
something like:

1) dyn irqs
2) APIC/IO_APIC handling integration
3) by-hand REVERT of dyn irqs, it was done by hand in order to not
   lose the #2 changes
4) interrupt remapping support

