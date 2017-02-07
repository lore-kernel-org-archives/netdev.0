From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: avoid infinite loop in tcp_splice_read()
Date: Mon, 06 Feb 2017 22:39:36 -0500 (EST)
Message-ID: <20170206.223936.1614855798292057873.davem@davemloft.net>
References: <1486162778.21871.119.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, w@1wt.eu, dvyukov@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56644 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751654AbdBGDji (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 22:39:38 -0500
In-Reply-To: <1486162778.21871.119.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 03 Feb 2017 14:59:38 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Splicing from TCP socket is vulnerable when a packet with URG flag is
> received and stored into receive queue.
> 
> __tcp_splice_read() returns 0, and sk_wait_data() immediately
> returns since there is the problematic skb in queue.
> 
> This is a nice way to burn cpu (aka infinite loop) and trigger
> soft lockups.
> 
> Again, this gem was found by syzkaller tool.
> 
> Fixes: 9c55e01c0cc8 ("[TCP]: Splice receive support.")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dmitry Vyukov  <dvyukov@google.com>
> Cc: Willy Tarreau <w@1wt.eu>

Applied and queued up for -stable, thanks Eric.
