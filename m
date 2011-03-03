From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net_sched: reduce fifo qdisc size
Date: Thu, 03 Mar 2011 11:10:56 -0800 (PST)
Message-ID: <20110303.111056.183042516.davem@davemloft.net>
References: <1299158865.2983.98.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54900
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752418Ab1CCTKT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 14:10:19 -0500
In-Reply-To: <1299158865.2983.98.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 03 Mar 2011 14:27:45 +0100

> Because of various alignements [SLUB / qdisc], we use 512 bytes of
> memory for one {p|b}fifo qdisc, instead of 256 bytes on 64bit arches and
> 192 bytes on 32bit ones.
> 
> Move the "u32 limit" inside "struct Qdisc" (no impact on other qdiscs)
> 
> Change qdisc_alloc(), first trying a regular allocation before an
> oversized one.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

It took me a moment to realize that leaving sch->padded uninitialized
in the sch==p case during allocation was legal ;-)

Applied, thanks!

