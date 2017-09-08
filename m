From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: fix memory leak with multiple tables during
 netns destruction
Date: Fri, 08 Sep 2017 09:49:18 -0700 (PDT)
Message-ID: <20170908.094918.377842401594545205.davem@davemloft.net>
References: <204659713af1979c26b8defb2b52e1668b4e5aad.1504859062.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57834 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754508AbdIHQtT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 12:49:19 -0400
In-Reply-To: <204659713af1979c26b8defb2b52e1668b4e5aad.1504859062.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Fri,  8 Sep 2017 10:26:19 +0200

> fib6_net_exit only frees the main and local tables. If another table was
> created with fib6_alloc_table, we leak it when the netns is destroyed.
> 
> Fix this in the same way ip_fib_net_exit cleans up tables, by walking
> through the whole hashtable of fib6_table's. We can get rid of the
> special cases for local and main, since they're also part of the
> hashtable.
> 
> Reproducer:
>     ip netns add x
>     ip -net x -6 rule add from 6003:1::/64 table 100
>     ip netns del x
> 
> Reported-by: Jianlin Shi <jishi@redhat.com>
> Fixes: 58f09b78b730 ("[NETNS][IPV6] ip6_fib - make it per network namespace")
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Applied and queued up for -stable, thanks.
