From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] udp: on peeking bad csum, drop packets even if
 not at head
Date: Tue, 22 Aug 2017 14:28:43 -0700 (PDT)
Message-ID: <20170822.142843.2204716875223379803.davem@davemloft.net>
References: <20170821213912.93333-1-willemdebruijn.kernel@gmail.com>
        <1503355232.2499.15.camel@edumazet-glaptop3.roam.corp.google.com>
        <1503419968.2499.33.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pabeni@redhat.com, willemb@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44380 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751651AbdHVV2o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 17:28:44 -0400
In-Reply-To: <1503419968.2499.33.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 22 Aug 2017 09:39:28 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> When peeking, if a bad csum is discovered, the skb is unlinked from
> the queue with __sk_queue_drop_skb and the peek operation restarted.
> 
> __sk_queue_drop_skb only drops packets that match the queue head.
> 
> This fails if the skb was found after the head, using SO_PEEK_OFF
> socket option. This causes an infinite loop.
> 
> We MUST drop this problematic skb, and we can simply check if skb was
> already removed by another thread, by looking at skb->next :
> 
> This pointer is set to NULL by the  __skb_unlink() operation, that might
> have happened only under the spinlock protection.
> 
> Many thanks to syzkaller team (and particularly Dmitry Vyukov who
> provided us nice C reproducers exhibiting the lockup) and Willem de
> Bruijn who provided first version for this patch and a test program.
> 
> Fixes: 627d2d6b5500 ("udp: enable MSG_PEEK at non-zero offset")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>

Applied and queued up for -stable.
