From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/3] NET: [SCHED] Qdisc changes and sch_rr added for multiqueue
Date: Thu, 28 Jun 2007 19:13:07 +0200
Message-ID: <4683EC23.2050705@trash.net>
References: <20070628162056.18728.20195.stgit@localhost.localdomain> <20070628162118.18728.64391.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	auke-jan.h.kok@intel.com, hadi@cyberus.ca
To: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55296 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756870AbXF1ROD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2007 13:14:03 -0400
In-Reply-To: <20070628162118.18728.64391.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PJ Waskiewicz wrote:
> +#ifdef CONFIG_NET_SCH_MULTIQUEUE
> +			if (q->mq)
> +				skb->queue_mapping = 
> +						q->prio2band[band&TC_PRIO_MAX];
> +			else
> +				skb->queue_mapping = 0;
> +#endif


Setting it to zero here is wrong, consider:

root qdisc: prio multiqueue
child qdisc: prio non-multiqueue

The top-level qdisc will set it, the child qdisc will unset it again.
When multiqueue is inactive it should not touch it.

I'll fix that as well.
