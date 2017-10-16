From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: check fn before doing FIB6_SUBTREE(fn)
Date: Mon, 16 Oct 2017 21:06:34 +0100 (WEST)
Message-ID: <20171016.210634.1944938562694750278.davem@davemloft.net>
References: <20171013220108.88710-1-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, kafai@fb.com
To: weiwan@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34440 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752518AbdJPUGg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 16:06:36 -0400
In-Reply-To: <20171013220108.88710-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>
Date: Fri, 13 Oct 2017 15:01:08 -0700

> From: Wei Wang <weiwan@google.com>
> 
> In fib6_locate(), we need to first make sure fn is not NULL before doing
> FIB6_SUBTREE(fn) to avoid crash.
> 
> This fixes the following static checker warning:
> net/ipv6/ip6_fib.c:1462 fib6_locate()
>          warn: variable dereferenced before check 'fn' (see line 1459)
> 
> net/ipv6/ip6_fib.c
>   1458          if (src_len) {
>   1459                  struct fib6_node *subtree = FIB6_SUBTREE(fn);
>                                                     ^^^^^^^^^^^^^^^^
> We shifted this dereference
> 
>   1460
>   1461                  WARN_ON(saddr == NULL);
>   1462                  if (fn && subtree)
>                             ^^
> before the check for NULL.
> 
>   1463                          fn = fib6_locate_1(subtree, saddr, src_len,
>   1464                                             offsetof(struct rt6_info, rt6i_src)
> 
> Fixes: 66f5d6ce53e6 ("ipv6: replace rwlock with rcu and spinlock in fib6_table")
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Wei Wang <weiwan@google.com>
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied.
