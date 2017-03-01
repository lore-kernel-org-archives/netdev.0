From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net] net: solve a NAPI race
Date: Wed, 01 Mar 2017 12:53:08 -0500 (EST)
Message-ID: <20170301.125308.178733058106222820.davem@davemloft.net>
References: <1488205298.9415.180.camel@edumazet-glaptop3.roam.corp.google.com>
        <1488226711.9415.204.camel@edumazet-glaptop3.roam.corp.google.com>
        <1488306890.9415.267.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.duyck@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48730 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753046AbdCARxJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Mar 2017 12:53:09 -0500
In-Reply-To: <1488306890.9415.267.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 28 Feb 2017 10:34:50 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> While playing with mlx4 hardware timestamping of RX packets, I found
> that some packets were received by TCP stack with a ~200 ms delay...
> 
> Since the timestamp was provided by the NIC, and my probe was added
> in tcp_v4_rcv() while in BH handler, I was confident it was not
> a sender issue, or a drop in the network.
> 
> This would happen with a very low probability, but hurting RPC
> workloads.
> 
> A NAPI driver normally arms the IRQ after the napi_complete_done(),
> after NAPI_STATE_SCHED is cleared, so that the hard irq handler can grab
> it.
> 
> Problem is that if another point in the stack grabs NAPI_STATE_SCHED bit
> while IRQ are not disabled, we might have later an IRQ firing and
> finding this bit set, right before napi_complete_done() clears it.
> 
> This can happen with busy polling users, or if gro_flush_timeout is
> used. But some other uses of napi_schedule() in drivers can cause this
> as well.
 ...
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
