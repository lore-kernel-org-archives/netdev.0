From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET : UDP can use sk_hash to speedup lookups
Date: Fri, 09 Feb 2007 15:45:11 -0800 (PST)
Message-ID: <20070209.154511.92582666.davem@davemloft.net>
References: <200702091036.58474.dada1@cosmosbay.com>
	<20070209.014344.63999119.davem@davemloft.net>
	<200702091844.16803.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37938
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752561AbXBIXpM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Feb 2007 18:45:12 -0500
In-Reply-To: <200702091844.16803.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 9 Feb 2007 18:44:16 +0100

> In a prior patch, I introduced a sk_hash field (__sk_common.skc_hash)  to let 
> tcp lookups use one cache line per unmatched entry instead of two.
> 
> We can also use sk_hash to speedup UDP part as well. We store in sk_hash the 
> hnum value, and use sk->sk_hash (same cache line than 'next' pointer), 
> instead of inet->num (different cache line)
> 
> Note : We still have a false sharing problem for SMP machines, because 
> sock_hold(sock) dirties the cache line containing the 'next' pointer. Not 
> counting the udp_hash_lock rwlock. (did someone mentioned RCU ? :) )
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks Eric.
