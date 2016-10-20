From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: relax listening_hash operations
Date: Thu, 20 Oct 2016 11:24:59 -0400 (EDT)
Message-ID: <20161020.112459.564839965287134365.davem@davemloft.net>
References: <1476937498.5650.102.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42076 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753405AbcJTPZB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 11:25:01 -0400
In-Reply-To: <1476937498.5650.102.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 19 Oct 2016 21:24:58 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> softirq handlers use RCU protection to lookup listeners,
> and write operations all happen from process context.
> We do not need to block BH for dump operations.
> 
> Also SYN_RECV since request sockets are stored in the ehash table :
> 
>  1) inet_diag_dump_icsk() no longer need to clear
>     cb->args[3] and cb->args[4] that were used as cursors while
>     iterating the old per listener hash table.
> 
>  2) Also factorize a test : No need to scan listening_hash[]
>     if r->id.idiag_dport is not zero.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
