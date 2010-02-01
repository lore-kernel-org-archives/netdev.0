From: Maxime Bizon <mbizon@freebox.fr>
Subject: Re: [PATCH ver2] Avoid enqueuing skb for default qdiscs
Date: Mon, 01 Feb 2010 10:52:20 +0100
Message-ID: <1265017940.32192.23.camel@sakura.staff.proxad.net>
References: <20090806114421.19208.39374.sendpatchset@localhost.localdomain>
Reply-To: mbizon@freebox.fr
Mime-Version: 1.0
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Jarek Poplawski <jarkao2@gmail.com>,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	kaber@trash.net
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g21.free.fr ([212.27.42.6]:45740 "EHLO smtp6-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750902Ab0BAJwd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Feb 2010 04:52:33 -0500
In-Reply-To: <20090806114421.19208.39374.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2009-08-06 at 17:14 +0530, Krishna Kumar wrote:

Hello,

> From: Krishna Kumar <krkumar2@in.ibm.com>
> 
> dev_queue_xmit enqueue's a skb and calls qdisc_run which
> dequeue's the skb and xmits it. In most cases, the skb that
> is enqueue'd is the same one that is dequeue'd (unless the
> queue gets stopped or multiple cpu's write to the same queue
> and ends in a race with qdisc_run). For default qdiscs, we
> can remove the redundant enqueue/dequeue and simply xmit the
> skb since the default qdisc is work-conserving.

Sorry old stuff, but I just noticed this.

One side effect of this patch is that tc now shows a lot of requeue for
slow interfaces (slow dsl link in my case), because sch_direct_xmit is
called even if device stopped its queue.

My first reflex was too investigate for a misbehaving driver (returning
TX_BUSY), but start_xmit is not even called, sch_direct_xmit notices
that queue is stopped, and just does a dequeue/requeue.

Since we're talking about slow interfaces, this has no impact on
performance, the requeue counter incrementing is just a bit scary.

Shouldn't we check for stopped queue earlier to avoid this ?

Regards,

-- 
Maxime


