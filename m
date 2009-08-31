From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] sched: Fix resource limiting in pfifo_fast
Date: Sun, 30 Aug 2009 22:19:59 -0700 (PDT)
Message-ID: <20090830.221959.172193969.davem@davemloft.net>
References: <20090830062344.6380.16713.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35467
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754270AbZHaFTp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 01:19:45 -0400
In-Reply-To: <20090830062344.6380.16713.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>
Date: Sun, 30 Aug 2009 11:53:44 +0530

> From: Krishna Kumar <krkumar2@in.ibm.com>
> 
> pfifo_fast_enqueue has this check:
>         if (skb_queue_len(list) < qdisc_dev(qdisc)->tx_queue_len) {
> 
> which allows each band to enqueue upto tx_queue_len skbs for a
> total of 3*tx_queue_len skbs. I am not sure if this was the
> intention of limiting in qdisc.
> 
> Patch compiled and 32 simultaneous netperf testing ran fine. Also:
> # tc -s qdisc show dev eth2
> qdisc pfifo_fast 0: root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>  Sent 16835026752 bytes 373116 pkt (dropped 0, overlimits 0 requeues 25) 
>  rate 0bit 0pps backlog 0b 0p requeues 25 
> 
> (I am taking next week off, so sorry for any delay in responding)
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>

This is probably just a thinko, nice catch.

I think I'll apply this to net-next-2.6, thanks!
