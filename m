From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: fix possible deadlock in TCP stack vs BPF
 filter
Date: Mon, 14 Aug 2017 22:32:19 -0700 (PDT)
Message-ID: <20170814.223219.1520974525933260255.davem@davemloft.net>
References: <1502757883.4936.41.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fengc@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50780 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751652AbdHOFcU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 01:32:20 -0400
In-Reply-To: <1502757883.4936.41.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 14 Aug 2017 17:44:43 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Filtering the ACK packet was not put at the right place.
> 
> At this place, we already allocated a child and put it
> into accept queue.
> 
> We absolutely need to call tcp_child_process() to release
> its spinlock, or we will deadlock at accept() or close() time.
> 
> Found by syzkaller team (Thanks a lot !)
> 
> Fixes: 8fac365f63c8 ("tcp: Add a tcp_filter hook before handle ack packet")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>

Applied, thanks.
