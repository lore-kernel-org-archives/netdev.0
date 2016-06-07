From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] net: sched: faster stats gathering
Date: Tue, 07 Jun 2016 16:37:31 -0700 (PDT)
Message-ID: <20160607.163731.1914725336655728632.davem@davemloft.net>
References: <1465231036-10674-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, jhs@mojatatu.com,
	eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59076 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932233AbcFGXhe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 19:37:34 -0400
In-Reply-To: <1465231036-10674-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Mon,  6 Jun 2016 09:37:14 -0700

> A while back, I sent one RFC patch using lockless stats gathering
> on 64bit arches.
> 
> This patch series does it more cleanly, using a seqcount.
> 
> Since qdisc/class stats are written at dequeue() time,
> we can ask the dequeue to change the seqcount, so that
> stats readers can avoid taking the root qdisc lock,
> and instead the typical read_seqcount_{begin|retry} guarded
> loop.
> 
> This does not change fast path costs, as the seqcount
> increments are not more expensive than the bit manipulation,
> and allows readers to not freeze the fast path anymore.

I like this, looks great!

Applied.
