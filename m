From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: restore skb->sk before pskb_trim() call
Date: Sun, 30 Apr 2017 22:23:38 -0400 (EDT)
Message-ID: <20170430.222338.928694349414886238.davem@davemloft.net>
References: <1493222963.6453.77.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andreyknvl@google.com, willemb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54122 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S642279AbdEACXk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 22:23:40 -0400
In-Reply-To: <1493222963.6453.77.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 26 Apr 2017 09:09:23 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> While testing a fix [1] in ___pskb_trim(), addressing the WARN_ON_ONCE()
> in skb_try_coalesce() reported by Andrey, I found that we had an skb
> with skb->sk set but no skb->destructor.
> 
> This invalidated heuristic found in commit 158f323b9868 ("net: adjust
> skb->truesize in pskb_expand_head()") and in cited patch.
> 
> Considering the BUG_ON(skb->sk) we have in skb_orphan(), we should
> restrain the temporary setting to a minimal section.
> 
> [1] https://patchwork.ozlabs.org/patch/755570/ 
>     net: adjust skb->truesize in ___pskb_trim()
> 
> Fixes: 8f917bba0042 ("bpf: pass sk to helper functions")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
