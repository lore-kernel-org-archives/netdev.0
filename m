From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next 0/3] tcp: better TCP_SKB_CB layout
Date: Sun, 28 Sep 2014 16:36:11 -0400 (EDT)
Message-ID: <20140928.163611.307968379739374310.davem@davemloft.net>
References: <1411836657-9542-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com, ncardwell@google.com,
	christoph.paasch@uclouvain.be
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47300 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751632AbaI1UgQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2014 16:36:16 -0400
In-Reply-To: <1411836657-9542-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Sat, 27 Sep 2014 09:50:54 -0700

> TCP had the assumption that IPCB and IP6CB are first members of skb->cb[]
> 
> This is fine, except that IPCB/IP6CB are used in TCP for a very short time
> in input path.
> 
> What really matters for TCP stack is to get skb->next,
> TCP_SKB_CB(skb)->seq, and TCP_SKB_CB(skb)->end_seq in the same cache line.
> 
> skb that are immediately consumed do not care because whole skb->cb[] is
> hot in cpu cache, while skb that sit in wocket write queue or receive queues
> do not need TCP_SKB_CB(skb)->header at all.
> 
> This patch set implements the prereq for IPv4, IPv6, and TCP to make this
> possible. This makes TCP more efficient.

Series applied, thanks.
