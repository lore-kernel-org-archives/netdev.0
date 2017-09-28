From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: Set sk_prot_creator when cloning sockets to
 the right proto
Date: Thu, 28 Sep 2017 10:34:33 -0700 (PDT)
Message-ID: <20170928.103433.848331604830380755.davem@davemloft.net>
References: <20170927003850.23731-1-cpaasch@apple.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: cpaasch@apple.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50256 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752333AbdI1Ree (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 13:34:34 -0400
In-Reply-To: <20170927003850.23731-1-cpaasch@apple.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Paasch <cpaasch@apple.com>
Date: Tue, 26 Sep 2017 17:38:50 -0700

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
> 
> A C-program to trigger this:
 ...
> As far as I can see, this bug has been there since the beginning of the
> git-days.
> 
> Signed-off-by: Christoph Paasch <cpaasch@apple.com>

Applied and queued up for -stable, thanks.
