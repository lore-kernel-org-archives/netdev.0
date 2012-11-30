From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] net: move inet_dport/inet_num in
 sock_common
Date: Fri, 30 Nov 2012 15:03:18 -0500 (EST)
Message-ID: <20121130.150318.1614281860316607800.davem@davemloft.net>
References: <1354304967.20109.10.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ling.ma.program@gmail.com,
	bhutchings@solarflare.com, joe@perches.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46738 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933620Ab2K3UDU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 15:03:20 -0500
In-Reply-To: <1354304967.20109.10.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 30 Nov 2012 11:49:27 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> commit 68835aba4d9b (net: optimize INET input path further)
> moved some fields used for tcp/udp sockets lookup in the first cache
> line of struct sock_common.
> 
> This patch moves inet_dport/inet_num as well, filling a 32bit hole
> on 64 bit arches and reducing number of cache line misses in lookups.
> 
> Also change INET_MATCH()/INET_TW_MATCH() to perform the ports match
> before addresses match, as this check is more discriminant.
> 
> Remove the hash check from MATCH() macros because we dont need to
> re validate the hash value after taking a refcount on socket, and
> use likely/unlikely compiler hints, as the sk_hash/hash check
> makes the following conditional tests 100% predicted by cpu.
> 
> Introduce skc_addrpair/skc_portpair pair values to better
> document the alignment requirements of the port/addr pairs
> used in the various MATCH() macros, and remove some casts.
> 
> The namespace check can also be done at last.
> 
> This slightly improves TCP/UDP lookup times.
> 
> IP/TCP early demux needs inet->rx_dst_ifindex and
> TCP needs inet->min_ttl, lets group them together in same cache line.
> 
> With help from Ben Hutchings & Joe Perches.
> 
> Idea of this patch came after Ling Ma proposal to move skc_hash
> to the beginning of struct sock_common, and should allow him
> to submit a final version of his patch. My tests show an improvement
> doing so.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks for fixing this up.
