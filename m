From: David Miller <davem@davemloft.net>
Subject: Re: [NET_SCHED]: Avoid requeue warning on dev_deactivate
Date: Thu, 10 May 2007 14:13:10 -0700 (PDT)
Message-ID: <20070510.141310.09953417.davem@davemloft.net>
References: <20070510125304.GA26090@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58995
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756135AbXEJVNH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 17:13:07 -0400
In-Reply-To: <20070510125304.GA26090@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 10 May 2007 22:53:04 +1000

> [NET_SCHED]: Avoid requeue warning on dev_deactivate
> 
> When we relinquish queue_lock in qdisc_restart and then retake it for
> requeueing, we might race against dev_deactivate and end up requeueing
> onto noop_qdisc.  This causes a warning to be printed.
> 
> This patch fixes this by checking this before we requeue.  As an added
> bonus, we can remove the same check in __qdisc_run which was added to
> prevent dev->gso_skb from being requeued when we're shutting down.
> 
> Even though we've had to add a new conditional in its place, it's better
> because it only happens on requeues rather than every single time that
> qdisc_run is called.
> 
> For this to work we also need to move the clearing of gso_skb up in
> dev_deactivate as now qdisc_restart can occur even after we wait for
> __LINK_STATE_QDISC_RUNNING to clear (but it won't do anything as long
> as the queue and gso_skb is already clear).
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>


Looks good, applied.
