From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/5 net-next] rhashtable: Extend RCU read lock into
 rhashtable_insert_rehash()
Date: Tue, 24 Mar 2015 19:40:44 +0000
Message-ID: <20150324194044.GD19251@casper.infradead.org>
References: <cover.1427202823.git.tgraf@suug.ch>
 <d12cd2734040e1cfb4fb04e78d51ec6c12a538c2.1427202823.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37788 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752459AbbCXTkp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 15:40:45 -0400
Content-Disposition: inline
In-Reply-To: <d12cd2734040e1cfb4fb04e78d51ec6c12a538c2.1427202823.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/24/15 at 02:18pm, Thomas Graf wrote:
> @@ -585,8 +585,8 @@ restart:
>  	if (unlikely(rht_grow_above_100(ht, tbl))) {
>  slow_path:
>  		spin_unlock_bh(lock);
> -		rcu_read_unlock();
>  		err = rhashtable_insert_rehash(ht);
> +		rcu_read_unlock();
>  		if (err)
>  			return err;

An alternative would be to start a new RCU section inside
rhashtable_insert_rehash(). This was the easier fix but I'm
fine either way.
