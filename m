From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net_sched: prio: use qdisc_dequeue_peeked
Date: Tue, 09 Aug 2011 21:52:38 -0700 (PDT)
Message-ID: <20110809.215238.910481277387937742.davem@davemloft.net>
References: <1312891483-30034-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36535 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750850Ab1HJEwu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2011 00:52:50 -0400
In-Reply-To: <1312891483-30034-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Tue,  9 Aug 2011 14:04:43 +0200

> commit 07bd8df5df4369487812bf85a237322ff3569b77
> (sch_sfq: fix peek() implementation) changed sfq to use generic
> peek helper.
> 
> This makes HFSC complain about a non-work-conserving child qdisc, if
> prio with sfq child is used within hfsc:
> 
> hfsc peeks into prio qdisc, which will then peek into sfq.
> returned skb is stashed in sch->gso_skb.
> 
> Next, hfsc tries to dequeue from prio, but prio will call sfq dequeue
> directly, which may return NULL instead of previously peeked-at skb.
> 
> Have prio call qdisc_dequeue_peeked, so sfq->dequeue() is
> not called in this case.
> 
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied and queued up for -stable, thanks!
