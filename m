From: David Miller <davem@davemloft.net>
Subject: Re: rhashtable: Remove unnecessary wmb for future_tbl
Date: Tue, 08 Dec 2015 22:47:08 -0500 (EST)
Message-ID: <20151208.224708.473911814887888793.davem@davemloft.net>
References: <20151208090904.GA17605@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, eric.dumazet@gmail.com, josh@joshtriplett.org,
	paulmck@linux.vnet.ibm.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49597 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752552AbbLIDrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 22:47:11 -0500
In-Reply-To: <20151208090904.GA17605@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 8 Dec 2015 17:09:04 +0800

> The patch 9497df88ab5567daa001829051c5f87161a81ff0 ("rhashtable:
> Fix reader/rehash race") added a pair of barriers.  In fact the
> wmb is superfluous because every subsequent write to the old or
> new hash table uses rcu_assign_pointer, which itself carriers a
> full barrier prior to the assignment.
> 
> Therefore we may remove the explicit wmb.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-next.
