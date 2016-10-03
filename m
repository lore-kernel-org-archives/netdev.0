From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] net: pktgen: fix pkt_size
Date: Mon, 03 Oct 2016 01:30:28 -0400 (EDT)
Message-ID: <20161003.013028.1884210069858462849.davem@davemloft.net>
References: <5277a40b08c491bd4ff8f6e3276718848f7406e8.1475246890.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bogdan.hamciuc@freescale.com,
        greearb@candelatech.com, sergei.shtylyov@cogentembedded.com
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38380 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750890AbcJCFac (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2016 01:30:32 -0400
In-Reply-To: <5277a40b08c491bd4ff8f6e3276718848f7406e8.1475246890.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Fri, 30 Sep 2016 16:56:45 +0200

> The commit 879c7220e828 ("net: pktgen: Observe needed_headroom
> of the device") increased the 'pkt_overhead' field value by
> LL_RESERVED_SPACE.
> As a side effect the generated packet size, computed as:
> 
> 	/* Eth + IPh + UDPh + mpls */
> 	datalen = pkt_dev->cur_pkt_size - 14 - 20 - 8 -
> 		  pkt_dev->pkt_overhead;
> 
> is decreased by the same value.
> The above changed slightly the behavior of existing pktgen users,
> and made the procfs interface somewhat inconsistent.
> Fix it by restoring the previous pkt_overhead value and using
> LL_RESERVED_SPACE as extralen in skb allocation.
> Also, change pktgen_alloc_skb() to only partially reserve
> the headroom to allow the caller to prefetch from ll header
> start.
> 
> v1 -> v2:
>  - fixed some typos in the comments
> 
> Fixes: 879c7220e828 ("net: pktgen: Observe needed_headroom of the device")
> Suggested-by: Ben Greear <greearb@candelatech.com>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied and queued up for -stable.
