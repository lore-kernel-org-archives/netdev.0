From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: fastopen: fix on syn-data transmit failure
Date: Tue, 19 Sep 2017 16:17:42 -0700 (PDT)
Message-ID: <20170919.161742.1970686060555960047.davem@davemloft.net>
References: <1505840757.29839.77.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ycheng@google.com, ncardwell@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50480 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751653AbdISXRn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 19:17:43 -0400
In-Reply-To: <1505840757.29839.77.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 19 Sep 2017 10:05:57 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Our recent change exposed a bug in TCP Fastopen Client that syzkaller
> found right away [1]
> 
> When we prepare skb with SYN+DATA, we attempt to transmit it,
> and we update socket state as if the transmit was a success.
> 
> In socket RTX queue we have two skbs, one with the SYN alone,
> and a second one containing the DATA.
> 
> When (malicious) ACK comes in, we now complain that second one had no
> skb_mstamp.
> 
> The proper fix is to make sure that if the transmit failed, we do not
> pretend we sent the DATA skb, and make it our send_head.
> 
> When 3WHS completes, we can now send the DATA right away, without having
> to wait for a timeout.
> 
> [1]
 ...
> Fixes: 8c72c65b426b ("tcp: update skb->skb_mstamp more carefully")
> Fixes: 783237e8daf1 ("net-tcp: Fast Open client - sending SYN-data")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>

Applied, thanks Eric.
