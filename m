From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3] ipv6: add rcu grace period before freeing
 fib6_node
Date: Tue, 22 Aug 2017 11:03:34 -0700 (PDT)
Message-ID: <20170822.110334.1274898045765726227.davem@davemloft.net>
References: <20170821164710.134367-1-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, kafai@fb.com
To: weiwan@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39240 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751713AbdHVSDe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 14:03:34 -0400
In-Reply-To: <20170821164710.134367-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>
Date: Mon, 21 Aug 2017 09:47:10 -0700

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
> Acked-by: Martin KaFai Lau <kafai@fb.com>

Applied and queued up for -stable, thanks.
