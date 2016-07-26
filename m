From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/sctp: terminate rhashtable walk correctly
Date: Mon, 25 Jul 2016 17:44:51 -0700 (PDT)
Message-ID: <20160725.174451.328776654071356819.davem@davemloft.net>
References: <1469259755-18079-1-git-send-email-vegard.nossum@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, nhorman@tuxdriver.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	lucien.xin@gmail.com, herbert@gondor.apana.org.au,
	stable@vger.kernel.org
To: vegard.nossum@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49280 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756958AbcGZAow (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2016 20:44:52 -0400
In-Reply-To: <1469259755-18079-1-git-send-email-vegard.nossum@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vegard Nossum <vegard.nossum@oracle.com>
Date: Sat, 23 Jul 2016 09:42:35 +0200

> I was seeing a lot of these:
 ...
> Apparently we always need to call rhashtable_walk_stop(), even when
> rhashtable_walk_start() fails:
> 
>  * rhashtable_walk_start - Start a hash table walk
>  * @iter:       Hash table iterator
>  *
>  * Start a hash table walk.  Note that we take the RCU lock in all
>  * cases including when we return an error.  So you must always call
>  * rhashtable_walk_stop to clean up.
> 
> otherwise we never call rcu_read_unlock() and we get the splat above.
> 
> See-also: 53fa1036 ("sctp: fix some rhashtable functions using in sctp proc/diag")
> See-also: f2dba9c6 ("rhashtable: Introduce rhashtable_walk_*")
> Cc: Xin Long <lucien.xin@gmail.com>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: stable@vger.kernel.org
> Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>

Applied and queued up for -stable, thanks.
