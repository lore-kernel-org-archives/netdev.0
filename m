From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/10] net_sched: defer skb freeing while
 changing qdiscs
Date: Wed, 15 Jun 2016 14:08:52 -0700 (PDT)
Message-ID: <20160615.140852.1530382419628030702.davem@davemloft.net>
References: <1465874519-25494-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
	eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34190 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753055AbcFOVIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 17:08:53 -0400
In-Reply-To: <1465874519-25494-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Mon, 13 Jun 2016 20:21:49 -0700

> qdiscs/classes are changed under RTNL protection and often
> while blocking BH and root qdisc spinlock.
> 
> When lots of skbs need to be dropped, we free
> them under these locks causing TX/RX freezes,
> and more generally latency spikes.
> 
> I saw spikes of 50+ ms on quite fast hardware...
> 
> This patch series adds a simple queue protected by RTNL
> where skbs can be placed until RTNL is released.
> 
> Note that this might also serve in the future for optional
> reinjection of packets when a qdisc is replaced.

Looks good, series applied, thanks Eric.
