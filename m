From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH 4/6] net neighbour: convert to RCU
Date: Tue, 29 Aug 2006 19:28:16 +0400
Message-ID: <20060829152816.GA24283@ms2.inr.ac.ru>
References: <20060828230748.827712918@localhost.localdomain> <20060828230915.587544687@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:26257 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S965027AbWH2P3B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 11:29:01 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060828230915.587544687@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> @@ -346,8 +354,8 @@ struct neighbour *neigh_lookup(struct ne
>  	
>  	NEIGH_CACHE_STAT_INC(tbl, lookups);
>  
> -	read_lock_bh(&tbl->lock);
> -	hlist_for_each_entry(n, tmp, &tbl->hash_buckets[hash_val], hlist) {
> +	rcu_read_lock();
> +	hlist_for_each_entry_rcu(n, tmp, &tbl->hash_buckets[hash_val], hlist) {
>  		if (dev == n->dev && !memcmp(n->primary_key, pkey, key_len)) {
>  			neigh_hold(n);
>  			NEIGH_CACHE_STAT_INC(tbl, hits);

Sure? Seems, you cannot grab refcnt here, the entry can be already
released.

Probably, you should do atomic_inc_and_test() here and restart lookup,
if it fails.

Alexey
