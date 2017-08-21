From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] ipv6: add rcu grace period before freeing
 fib6_node
Date: Sun, 20 Aug 2017 19:59:54 -0700 (PDT)
Message-ID: <20170820.195954.75794556487638223.davem@davemloft.net>
References: <20170820003408.133176-1-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, kafai@fb.com
To: weiwan@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49104 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753414AbdHUC7z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Aug 2017 22:59:55 -0400
In-Reply-To: <20170820003408.133176-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>
Date: Sat, 19 Aug 2017 17:34:08 -0700

> From: Wei Wang <weiwan@google.com>
> 
> We currently keep rt->rt6i_node pointing to the fib6_node for the route.
> And some functions make use of this pointer to dereference the fib6_node
> from rt structure, e.g. rt6_check(). However, as there is neither
> refcount nor rcu taken when dereferencing rt->rt6i_node, it could
> potentially cause crashes as rt->rt6i_node could be set to NULL by other
> CPUs when doing a route deletion.
> This patch introduces an rcu grace period before freeing fib6_node and
> makes sure the functions that dereference it takes rcu_read_lock().
> 
> Note: there is no "Fixes" tag because this bug was there in a very
> early stage.
> 
> Signed-off-by: Wei Wang <weiwan@google.com>
> Acked-by: Eric Dumazet <edumazet@google.com>
> ---
> v2: removed one extra empty line

Goodness.... where to start.

If this bug has been around forever, why did you make this patch
against net-next instead of net?  (I can tell just by looking at
the patch because rt6_free_pcpu() is static in 'net' yet it is
not static in the diff hunk which matches net-next)

And if you made it against net-next, why are you saying "net" in
your subject line instead of "[PATCH net-next v2]"?

Please sort this out properly, and resubmit.

Thank you.
