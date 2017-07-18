From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] udp: preserve skb->dst if required for IP
 options processing
Date: Tue, 18 Jul 2017 12:00:40 -0700 (PDT)
Message-ID: <20170718.120040.847904052360889957.davem@davemloft.net>
References: <8261bc94db747d35e48c4201b1f8bd52042ec345.1500363698.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
        hannes@stressinduktion.org
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54532 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751424AbdGRTAl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 15:00:41 -0400
In-Reply-To: <8261bc94db747d35e48c4201b1f8bd52042ec345.1500363698.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Tue, 18 Jul 2017 11:57:55 +0200

> Eric noticed that in udp_recvmsg() we still need to access
> skb->dst while processing the IP options.
> Since commit 0a463c78d25b ("udp: avoid a cache miss on dequeue")
> skb->dst is no more available at recvmsg() time and bad things
> will happen if we enter the relevant code path.
> 
> This commit address the issue, avoid clearing skb->dst if
> any IP options are present into the relevant skb.
> Since the IP CB is contained in the first skb cacheline, we can
> test it to decide to leverage the consume_stateless_skb()
> optimization, without measurable additional cost in the faster
> path.
> 
> v1 -> v2: updated commit message tags
> 
> Fixes: 0a463c78d25b ("udp: avoid a cache miss on dequeue")
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Reported-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied, thank you.
