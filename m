From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/3] NET: [SCHED] Qdisc changes and sch_rr added for multiqueue
Date: Mon, 25 Jun 2007 00:22:10 +0200
Message-ID: <467EEE92.9040702@trash.net>
References: <20070623213614.18241.45511.stgit@localhost.localdomain> <20070623213633.18241.24627.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	auke-jan.h.kok@intel.com, hadi@cyberus.ca
To: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52137 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751004AbXFXWWY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jun 2007 18:22:24 -0400
In-Reply-To: <20070623213633.18241.24627.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PJ Waskiewicz wrote:
> +	/* If we're multiqueue, make sure the number of incoming bands
> +	 * matches the number of queues on the device we're associating with.
> +	 */
> +	if (tb[TCA_PRIO_MQ - 1])
> +		q->mq = *(unsigned char *)RTA_DATA(tb[TCA_PRIO_MQ - 1]);
> +
> +	if (q->mq && (qopt->bands != sch->dev->egress_subqueue_count))
> +		return -EINVAL;


A nice thing you could do for the user here is use
egress_subqueue_count as default when qopt->bands == 0
(and change tc prio to accept 0 in case it doesn't).
