From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: reduce skb overhead in selected places
Date: Wed, 25 Jan 2017 13:17:17 -0500 (EST)
Message-ID: <20170125.131717.489451306351372553.davem@davemloft.net>
References: <1485298656.16328.355.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57170 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751685AbdAYSRT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 13:17:19 -0500
In-Reply-To: <1485298656.16328.355.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 24 Jan 2017 14:57:36 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> tcp_add_backlog() can use skb_condense() helper to get better
> gains and less SKB_TRUESIZE() magic. This only happens when socket
> backlog has to be used.
> 
> Some attacks involve specially crafted out of order tiny TCP packets,
> clogging the ofo queue of (many) sockets.
> Then later, expensive collapse happens, trying to copy all these skbs
> into single ones.
> This unfortunately does not work if each skb has no neighbor in TCP
> sequence order.
> 
> By using skb_condense() if the skb could not be coalesced to a prior
> one, we defeat these kind of threats, potentially saving 4K per skb
> (or more, since this is one page fragment).
> 
> A typical NAPI driver allocates gro packets with GRO_MAX_HEAD bytes
> in skb->head, meaning the copy done by skb_condense() is limited to
> about 200 bytes.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
