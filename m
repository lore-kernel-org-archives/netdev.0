From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH V2 3/9] net: frag, move LRU list maintenance
 outside of rwlock
Date: Thu, 29 Nov 2012 12:48:39 -0500 (EST)
Message-ID: <20121129.124839.963269461515687321.davem@davemloft.net>
References: <20121129161019.17754.29670.stgit@dragon>
	<20121129161137.17754.48002.stgit@dragon>
	<1354211004.3299.12.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, fw@strlen.de, netdev@vger.kernel.org,
	pablo@netfilter.org, tgraf@suug.ch, amwang@redhat.com,
	kaber@trash.net, paulmck@linux.vnet.ibm.com,
	herbert@gondor.hengli.com.au
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33694 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753239Ab2K2Rsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 12:48:41 -0500
In-Reply-To: <1354211004.3299.12.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 29 Nov 2012 09:43:24 -0800

> Use a schem with a hash table of 256 (or 1024) slots.
> 
> Each slot/bucket has : 
>   - Its own spinlock.
>   - List of items
>   - A limit of 5 (or so) elems in the list.
> 
> No more LRU, no more rehash (thanks to jhash and the random seed at boot
> or first frag created), no more reader-writer lock.
> 
> Use a percpu_counter to implement ipfrag_low_thresh/ipfrag_high_thresh

If we limit the chain sizes to 5 elements, there is no need for
any thresholds at all.
