From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] net-gro: Prepare GRO stack for the
 upcoming tunneling support
Date: Thu, 12 Dec 2013 13:48:08 -0500 (EST)
Message-ID: <20131212.134808.116829709834251220.davem@davemloft.net>
References: <1386824025-27413-1-git-send-email-hkchu@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, herbert@gondor.apana.org.au,
	ogerlitz@mellanox.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org
To: hkchu@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38937 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752160Ab3LLSsK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 13:48:10 -0500
In-Reply-To: <1386824025-27413-1-git-send-email-hkchu@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "H.K. Jerry Chu" <hkchu@google.com>
Date: Wed, 11 Dec 2013 20:53:45 -0800

> From: Jerry Chu <hkchu@google.com>
> 
> This patch modifies the GRO stack to avoid the use of "network_header"
> and associated macros like ip_hdr() and ipv6_hdr() in order to allow
> an arbitary number of IP hdrs (v4 or v6) to be used in the
> encapsulation chain. This lays the foundation for various IP
> tunneling support (IP-in-IP, GRE, VXLAN, SIT,...) to be added later.
> 
> With this patch, the GRO stack traversing now is mostly based on
> skb_gro_offset rather than special hdr offsets saved in skb (e.g.,
> skb->network_header). As a result all but the top layer (i.e., the
> the transport layer) must have hdrs of the same length in order for
> a pkt to be considered for aggregation. Therefore when adding a new
> encap layer (e.g., for tunneling), one must check and skip flows
> (e.g., by setting NAPI_GRO_CB(p)->same_flow to 0) that have a
> different hdr length.
> 
> Note that unlike the network header, the transport header can and
> will continue to be set by the GRO code since there will be at
> most one "transport layer" in the encap chain.
> 
> Signed-off-by: H.K. Jerry Chu <hkchu@google.com>
> Suggested-by: Eric Dumazet <edumazet@google.com>
> Reviewed-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
