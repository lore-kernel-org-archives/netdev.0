From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: fix tcp_send_syn_data()
Date: Sat, 21 Oct 2017 01:44:34 +0100 (WEST)
Message-ID: <20171021.014434.726585284125917383.davem@davemloft.net>
References: <1508361630.31614.142.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com, edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45822 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752925AbdJUAoi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 20:44:38 -0400
In-Reply-To: <1508361630.31614.142.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 18 Oct 2017 14:20:30 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> syn_data was allocated by sk_stream_alloc_skb(), meaning
> its destructor and _skb_refdst fields are mangled.
> 
> We need to call tcp_skb_tsorted_anchor_cleanup() before
> calling kfree_skb() or kernel crashes.
> 
> Bug was reported by syzkaller bot.
> 
> Fixes: e2080072ed2d ("tcp: new list for sent but unacked skbs for RACK recovery")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>

Applied.
