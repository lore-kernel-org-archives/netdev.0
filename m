From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: pktgen: remove rcu locking in
 pktgen_change_name()
Date: Mon, 17 Oct 2016 10:53:48 -0400 (EDT)
Message-ID: <20161017.105348.849516001766766698.davem@davemloft.net>
References: <1476546649.5650.51.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brouer@redhat.com, jsperbeck@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56266 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754297AbcJQOxx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 10:53:53 -0400
In-Reply-To: <1476546649.5650.51.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 15 Oct 2016 17:50:49 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> After Jesper commit back in linux-3.18, we trigger a lockdep
> splat in proc_create_data() while allocating memory from
> pktgen_change_name().
> 
> This patch converts t->if_lock to a mutex, since it is now only
> used from control path, and adds proper locking to pktgen_change_name()
> 
> 1) pktgen_thread_lock to protect the outer loop (iterating threads)
> 2) t->if_lock to protect the inner loop (iterating devices)
> 
> Note that before Jesper patch, pktgen_change_name() was lacking proper
> protection, but lockdep was not able to detect the problem.
> 
> Fixes: 8788370a1d4b ("pktgen: RCU-ify "if_list" to remove lock in next_to_run()")
> Reported-by: John Sperbeck <jsperbeck@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks.
