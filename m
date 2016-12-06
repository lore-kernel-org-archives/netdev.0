From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/udp: do not touch skb->peeked unless really needed
Date: Tue, 06 Dec 2016 10:42:37 -0500 (EST)
Message-ID: <20161206.104237.412296597467530333.davem@davemloft.net>
References: <1480944138.4694.37.camel@redhat.com>
        <1480948133.18162.527.camel@edumazet-glaptop3.roam.corp.google.com>
        <1480960639.18162.556.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pabeni@redhat.com, netdev@vger.kernel.org, willemb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42024 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754018AbcLFPmj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 10:42:39 -0500
In-Reply-To: <1480960639.18162.556.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 05 Dec 2016 09:57:19 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> In UDP recvmsg() path we currently access 3 cache lines from an skb
> while holding receive queue lock, plus another one if packet is
> dequeued, since we need to change skb->next->prev
> 
> 1st cache line (contains ->next/prev pointers, offsets 0x00 and 0x08)
> 2nd cache line (skb->len & skb->peeked, offsets 0x80 and 0x8e)
> 3rd cache line (skb->truesize/users, offsets 0xe0 and 0xe4)
> 
> skb->peeked is only needed to make sure 0-length packets are properly
> handled while MSG_PEEK is operated.
> 
> I had first the intent to remove skb->peeked but the "MSG_PEEK at
> non-zero offset" support added by Sam Kumar makes this not possible.
> 
> This patch avoids one cache line miss during the locked section, when
> skb->len and skb->peeked do not have to be read.
> 
> It also avoids the skb_set_peeked() cost for non empty UDP datagrams.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
