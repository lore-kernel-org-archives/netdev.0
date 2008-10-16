From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 0/6] Add qdisc->ops->peek() support.
Date: Thu, 16 Oct 2008 09:46:45 +0000
Message-ID: <20081016094645.GA19019@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:42527 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752892AbYJPJqw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2008 05:46:52 -0400
Received: by ug-out-1314.google.com with SMTP id k3so1628173ugf.37
        for <netdev@vger.kernel.org>; Thu, 16 Oct 2008 02:46:50 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Subject: Re: [PATCH 00/14]: Killing qdisc->ops->requeue().]
On Tue, Oct 14, 2008 at 10:44:13PM +0200, Patrick McHardy wrote:
...
> I think we really need a peek operation since most qdiscs do have
> some internal priorization. The question is whether all qdiscs need
> it; I tend to think no. Plugging two non-work-conserving qdiscs
> together doesn't make much sense, so we could just prevent this.
> This means we would only need to add ->peek support to the
> work-conserving qdiscs, which looks pretty easy in all cases.
> We actually don't even have to prevent plugging two non-work-conserving
> qdiscs, the ones that need the peek operation could just check whether
> the inner qdisc supports it.
>
> Just as a demonstration how easy adding a peek operation to the
> work-conserving qdiscs actually is. It doesn't need to keep or change
> any internal state in many cases thanks to the guarantee that the
> packet will either be dequeued or, if another packet arrives, the
> upper qdisc will immediately ->peek again to reevaluate the state.

So here is my try (I hope I didn't miss Patrick's intentions to much).

PATCH 6/6 adds my simple idea not to prevent even nonsense configs.
It is optional.

Thanks,
Jarek P.

PS: after this patchset only netem_enqueue() needs qdisc->requeue(),
but I hope this won't take too long.

 include/net/sch_generic.h |   29 +++++++++++++++++++++++++++++
 net/sched/sch_api.c       |    6 ++++++
 net/sched/sch_atm.c       |   23 ++++++++++++++++++-----
 net/sched/sch_blackhole.c |    1 +
 net/sched/sch_cbq.c       |    1 +
 net/sched/sch_dsmark.c    |   10 ++++++++++
 net/sched/sch_fifo.c      |    2 ++
 net/sched/sch_generic.c   |   16 ++++++++++++++++
 net/sched/sch_gred.c      |    1 +
 net/sched/sch_hfsc.c      |   15 ++++-----------
 net/sched/sch_htb.c       |    1 +
 net/sched/sch_multiq.c    |   29 +++++++++++++++++++++++++++++
 net/sched/sch_netem.c     |   15 +++++++--------
 net/sched/sch_prio.c      |   14 ++++++++++++++
 net/sched/sch_red.c       |    9 +++++++++
 net/sched/sch_sfq.c       |   12 ++++++++++++
 net/sched/sch_tbf.c       |   13 ++++++-------
 net/sched/sch_teql.c      |    9 +++++++++
 18 files changed, 175 insertions(+), 31 deletions(-)
