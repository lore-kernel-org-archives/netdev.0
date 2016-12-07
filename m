From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: sock_rps_record_flow() is for connected
 sockets
Date: Wed, 07 Dec 2016 10:47:47 -0500 (EST)
Message-ID: <20161207.104747.1515574562496806645.davem@davemloft.net>
References: <1481051786.7129.22.camel@redhat.com>
        <1481052922.18162.605.camel@edumazet-glaptop3.roam.corp.google.com>
        <1481081570.18162.626.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pabeni@redhat.com, netdev@vger.kernel.org, willemb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34482 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752156AbcLGPrw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 10:47:52 -0500
In-Reply-To: <1481081570.18162.626.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 06 Dec 2016 19:32:50 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Paolo noticed a cache line miss in UDP recvmsg() to access
> sk_rxhash, sharing a cache line with sk_drops.
> 
> sk_drops might be heavily incremented by cpus handling a flood targeting
> this socket.
> 
> We might place sk_drops on a separate cache line, but lets try
> to avoid wasting 64 bytes per socket just for this, since we have
> other bottlenecks to take care of.
> 
> sock_rps_record_flow() should only access sk_rxhash for connected
> flows.
> 
> Testing sk_state for TCP_ESTABLISHED covers most of the cases for
> connected sockets, for a zero cost, since system calls using
> sock_rps_record_flow() also access sk->sk_prot which is on the
> same cache line.
> 
> A follow up patch will provide a static_key (Jump Label) since most
> hosts do not even use RFS.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Paolo Abeni <pabeni@redhat.com>

Applied, thanks Eric.
