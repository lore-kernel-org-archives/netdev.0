From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: avoid two atomic operations in fast
 clones
Date: Tue, 09 Dec 2014 13:40:39 -0500 (EST)
Message-ID: <20141209.134039.1896885552629089445.davem@davemloft.net>
References: <1417655079.5303.152.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, clm@fb.com, sd@queasysnail.net,
	subramanian.vijay@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37388 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751252AbaLISkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 13:40:43 -0500
In-Reply-To: <1417655079.5303.152.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 03 Dec 2014 17:04:39 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Commit ce1a4ea3f125 ("net: avoid one atomic operation in skb_clone()")
> took the wrong way to save one atomic operation.
> 
> It is actually possible to avoid two atomic operations, if we
> do not change skb->fclone values, and only rely on clone_ref
> content to signal if the clone is available or not.
> 
> skb_clone() can simply use the fast clone if clone_ref is 1.
> 
> kfree_skbmem() can avoid the atomic_dec_and_test() if clone_ref is 1.
> 
> Note that because we usually free the clone before the original skb,
> this particular attempt is only done for the original skb to have better
> branch prediction.
> 
> SKB_FCLONE_FREE is removed.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
