From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] net: Revert "net: avoid one atomic operation in
 skb_clone()"
Date: Fri, 21 Nov 2014 15:27:07 -0500 (EST)
Message-ID: <20141121.152707.1184550321197091769.davem@davemloft.net>
References: <20141121180510.GA22112@kria>
	<1416598161.8629.120.camel@edumazet-glaptop2.roam.corp.google.com>
	<1416599236.8629.124.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sd@queasysnail.net, clm@fb.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38612 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750939AbaKUU1K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 15:27:10 -0500
In-Reply-To: <1416599236.8629.124.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 21 Nov 2014 11:47:16 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Not sure what I was thinking, but doing anything after
> releasing a refcount is suicidal or/and embarrassing.
> 
> By the time we set skb->fclone to SKB_FCLONE_FREE, another cpu
> could have released last reference and freed whole skb.
> 
> We potentially corrupt memory or trap if CONFIG_DEBUG_PAGEALLOC is set.
> 
> Reported-by: Chris Mason <clm@fb.com>
> Fixes: ce1a4ea3f1258 ("net: avoid one atomic operation in skb_clone()")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Sabrina Dubroca <sd@queasysnail.net>
> ---
> v2: the revert went wrong, as SKB_FCLONE_UNAVAILABLE
>     was later replaced by SKB_FCLONE_FREE, spotted by Sabrina Dubroca

Applied, thanks Eric.
