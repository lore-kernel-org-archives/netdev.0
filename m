From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [net-next-2.6 PATCH v2 3/3] net_sched: implement a root
	container qdisc sch_mclass
Date: Fri, 31 Dec 2010 09:25:44 +0000
Message-ID: <20101231092543.GA7809@ff.dom.local>
References: <20101221192930.9703.63791.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, hadi@cyberus.ca,
	shemminger@vyatta.com, tgraf@infradead.org, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, nhorman@tuxdriver.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:55340 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750894Ab0LaJZw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Dec 2010 04:25:52 -0500
Received: by fxm20 with SMTP id 20so11752252fxm.19
        for <netdev@vger.kernel.org>; Fri, 31 Dec 2010 01:25:51 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20101221192930.9703.63791.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-12-21 20:29, John Fastabend wrote:
> This implements a mclass 'multi-class' queueing discipline that by
> default creates multiple mq qdisc's one for each traffic class. Each
> mq qdisc then owns a range of queues per the netdev_tc_txq mappings.

Btw, you could also consider better name (mqprio?) because there're
many 'multi-class' queueing disciplines around.

> +static int mclass_parse_opt(struct net_device *dev, struct tc_mclass_qopt *qopt)
> +{
> +	int i, j;
> +
> +	/* Verify TC offset and count are sane */

if (qopt->num_tc > TC_MAX_QUEUE) ?
	return -EINVAL;

> +	for (i = 0; i < qopt->num_tc; i++) {
> +		int last = qopt->offset[i] + qopt->count[i];
> +		if (last > dev->num_tx_queues)

if (last >= dev->num_tx_queues) ?

> +			return -EINVAL;
> +		for (j = i + 1; j < qopt->num_tc; j++) {
> +			if (last > qopt->offset[j])

if (last >= qopt->offset[j]) ?

Jarek P.
