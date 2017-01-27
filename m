From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: adjust skb->truesize in
 pskb_expand_head()
Date: Fri, 27 Jan 2017 12:03:44 -0500 (EST)
Message-ID: <20170127.120344.536515545735368429.davem@davemloft.net>
References: <1485476480.5145.194.camel@edumazet-glaptop3.roam.corp.google.com>
        <1485529887.6360.50.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, slavash@mellanox.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42712 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933051AbdA0RFU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 12:05:20 -0500
In-Reply-To: <1485529887.6360.50.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 27 Jan 2017 07:11:27 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Slava Shwartsman reported a warning in skb_try_coalesce(), when we
> detect skb->truesize is completely wrong.
> 
> In his case, issue came from IPv6 reassembly coping with malicious
> datagrams, that forced various pskb_may_pull() to reallocate a bigger
> skb->head than the one allocated by NIC driver before entering GRO
> layer.
> 
> Current code does not change skb->truesize, leaving this burden to
> callers if they care enough.
> 
> Blindly changing skb->truesize in pskb_expand_head() is not
> easy, as some producers might track skb->truesize, for example
> in xmit path for back pressure feedback (sk->sk_wmem_alloc)
> 
> We can detect the cases where it should be safe to change
> skb->truesize :
> 
> 1) skb is not attached to a socket.
> 2) If it is attached to a socket, destructor is sock_edemux()
> 
> My audit gave only two callers doing their own skb->truesize
> manipulation.
> 
> I had to remove skb parameter in sock_edemux macro when
> CONFIG_INET is not set to avoid a compile error.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Slava Shwartsman <slavash@mellanox.com>

Looks good, applied, thanks Eric.
