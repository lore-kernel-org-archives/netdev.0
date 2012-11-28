From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: move inet_dport/inet_num in
 sock_common
Date: Wed, 28 Nov 2012 11:48:35 -0500 (EST)
Message-ID: <20121128.114835.1005932954047935079.davem@davemloft.net>
References: <1354075918.14302.77.camel@edumazet-glaptop>
	<1354102061.14302.84.camel@edumazet-glaptop>
	<1354107378.14302.149.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ling.ma.program@gmail.com, joe@perches.com,
	bhutchings@solarflare.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50411 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755197Ab2K1Qsi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 11:48:38 -0500
In-Reply-To: <1354107378.14302.149.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 28 Nov 2012 04:56:18 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> commit 68835aba4d9b (net: optimize INET input path further)
> moved some fields used for tcp/udp sockets lookup in the first cache
> line of struct sock_common.
> 
> This patch moves inet_dport/inet_num as well, filling a 32bit hole
> on 64 bit arches and reducing number of cache line misses.
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
> With help from Ben Hutchings & Joe Perches.
> 
> Idea of this patch came after Ling Ma proposal to move skc_hash
> to the beginning of struct sock_common, and should allow him
> to submit a final version of his patch.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

I like this a lot, applied, thanks Eric!
