From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: ipv6: Add early demux handler for UDP
 unicast
Date: Sun, 12 Mar 2017 22:54:48 -0700 (PDT)
Message-ID: <20170312.225448.798984501964691999.davem@davemloft.net>
References: <1489016209-19344-1-git-send-email-subashab@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52666 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751856AbdCMFyt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 01:54:49 -0400
In-Reply-To: <1489016209-19344-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Date: Wed,  8 Mar 2017 16:36:49 -0700

> While running a single stream UDPv6 test, we observed that amount
> of CPU spent in NET_RX softirq was much greater than UDPv4 for an
> equivalent receive rate. The test here was run on an ARM64 based
> Android system. On further analysis with perf, we found that UDPv6
> was spending significant time in the statistics netfilter targets
> which did socket lookup per packet. These statistics rules perform
> a lookup when there is no socket associated with the skb. Since
> there are multiple instances of these rules based on UID, there
> will be equal number of lookups per skb.
> 
> By introducing early demux for UDPv6, we avoid the redundant lookups.
> This also helped to improve the performance (800Mbps -> 870Mbps) on a
> CPU limited system in a single stream UDPv6 receive test with 1450
> byte sized datagrams using iperf.
> 
> v1->v2: Use IPv6 cookie to validate dst instead of 0 as suggested
> by Eric
> 
> Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>

Applied, thanks.
