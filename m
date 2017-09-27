From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: Set sk_prot_creator when cloning sockets to
 the right proto
Date: Tue, 26 Sep 2017 23:14:57 -0700
Message-ID: <1506492897.6617.33.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170927003850.23731-1-cpaasch@apple.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Christoph Paasch <cpaasch@apple.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35560 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750917AbdI0GPB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 02:15:01 -0400
Received: by mail-io0-f193.google.com with SMTP id d16so5584964ioj.2
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2017 23:15:00 -0700 (PDT)
In-Reply-To: <20170927003850.23731-1-cpaasch@apple.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-09-26 at 17:38 -0700, Christoph Paasch wrote:
> sk->sk_prot and sk->sk_prot_creator can differ when the app uses
> IPV6_ADDRFORM (transforming an IPv6-socket to an IPv4-one).
> Which is why sk_prot_creator is there to make sure that sk_prot_free()
> does the kmem_cache_free() on the right kmem_cache slab.
> 
> Now, if such a socket gets transformed back to a listening socket (using
> connect() with AF_UNSPEC) we will allocate an IPv4 tcp_sock through
> sk_clone_lock() when a new connection comes in. But sk_prot_creator will
> still point to the IPv6 kmem_cache (as everything got copied in
> sk_clone_lock()). When freeing, we will thus put this
> memory back into the IPv6 kmem_cache although it was allocated in the
> IPv4 cache. I have seen memory corruption happening because of this.
> 
> With slub-debugging and MEMCG_KMEM enabled this gives the warning
> 	"cache_from_obj: Wrong slab cache. TCPv6 but object is from TCP"

Nice catch, thanks !

Reviewed-by: Eric Dumazet <edumazet@google.com>
