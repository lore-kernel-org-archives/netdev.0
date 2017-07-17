From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] inetpeer: remove AVL implementation in favor
 of RB tree
Date: Mon, 17 Jul 2017 08:59:15 -0700 (PDT)
Message-ID: <20170717.085915.556973296335189682.davem@davemloft.net>
References: <1499270405.16045.8.camel@edumazet-glaptop3.roam.corp.google.com>
        <1500285370.5566.20.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, fw@strlen.de, netfilter-devel@vger.kernel.org,
        netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53092 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751284AbdGQP7Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 11:59:16 -0400
In-Reply-To: <1500285370.5566.20.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 17 Jul 2017 02:56:10 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> As discussed in Faro during Netfilter Workshop 2017, RB trees can be
> used with RCU, using a seqlock.
> 
> Note that net/rxrpc/conn_service.c is already using this.
> 
> This patch converts inetpeer from AVL tree to RB tree, since it allows
> to remove private AVL implementation in favor of shared RB code.
> 
> $ size net/ipv4/inetpeer.before net/ipv4/inetpeer.after
>    text    data     bss     dec     hex filename
>    3195      40     128    3363     d23 net/ipv4/inetpeer.before
>    1562      24       0    1586     632 net/ipv4/inetpeer.after
> 
> The same technique can be used to speed up
> net/netfilter/nft_set_rbtree.c (removing rwlock contention in fast path)
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks for doing this Eric.
