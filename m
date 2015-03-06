From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: gro: remove obsolete code from
 skb_gro_receive()
Date: Fri, 06 Mar 2015 01:04:41 -0500 (EST)
Message-ID: <20150306.010441.1755035570297062470.davem@davemloft.net>
References: <1425493600.5130.208.camel@edumazet-glaptop2.roam.corp.google.com>
	<1425592068.5130.266.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40496 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755781AbbCFGEn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 01:04:43 -0500
In-Reply-To: <1425592068.5130.266.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 05 Mar 2015 13:47:48 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Some drivers use copybreak to copy tiny frames into smaller skb,
> and this smaller skb might not have skb->head_frag set for various
> reasons.
> 
> skb_gro_receive() currently doesn't allow to aggregate the smaller skb
> into the previous GRO packet if this GRO packet has at least 2 MSS in
> it.
> 
> Following workload easily demonstrates the problem.
> 
> netperf -t TCP_RR -H target -- -r 3000,3000 
> 
> (tcpdump shows one GRO packet with 2 MSS, plus one additional packet of
> 104 bytes that should have been appended.)
> 
> It turns out that we can remove code from skb_gro_receive(), because
> commit 8a29111c7ca6 ("net: gro: allow to build full sized skb") and its
> followups removed the assumption that a GRO packet with a frag_list had
> to have an empty head.
> 
> Removing this code allows the aggregation of the last (incomplete) frame
> in some RPC workloads. Note that tcp_gro_receive() already takes care of
> forcing a flush if necessary, including this case.
> 
> If we want to avoid using frag_list in the first place (in forwarding
> workloads for example, as the outgoing NIC is generally not able to cope
> with skbs having a frag_list), we need to address this separately.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> ---
> v2: removed headroom & nskb variables, no longer needed.

Looks good, applied, thanks!
