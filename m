From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: sk_buff rbnode reorg
Date: Tue, 19 Sep 2017 15:20:37 -0700 (PDT)
Message-ID: <20170919.152037.1699896657960145386.davem@davemloft.net>
References: <1505797616.29839.40.camel@edumazet-glaptop3.roam.corp.google.com>
        <1505823264.29839.54.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, soheil@google.com, weiwan@google.com,
        willemb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48338 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751479AbdISWUi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 18:20:38 -0400
In-Reply-To: <1505823264.29839.54.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 19 Sep 2017 05:14:24 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> skb->rbnode shares space with skb->next, skb->prev and skb->tstamp
> 
> Current uses (TCP receive ofo queue and netem) need to save/restore
> tstamp, while skb->dev is either NULL (TCP) or a constant for a given
> queue (netem).
>     
> Since we plan using an RB tree for TCP retransmit queue to speedup SACK
> processing with large BDP, this patch exchanges skb->dev and
> skb->tstamp.
>     
> This saves some overhead in both TCP and netem.
> 
> v2: removes the swtstamp field from struct tcp_skb_cb
>     
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Looks great, applied, thanks Eric.
