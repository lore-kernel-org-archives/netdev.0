From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: net_sched 07/07: add classful multiqueue dummy scheduler
Date: Mon, 7 Sep 2009 21:24:29 +0200
Message-ID: <20090907192429.GC4451@ami.dom.local>
References: <20090906200409.GB8833@ami.dom.local>
 <4AA50A49.7010905@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:34549 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750724AbZIGTYz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2009 15:24:55 -0400
Received: by bwz19 with SMTP id 19so1762421bwz.37
        for <netdev@vger.kernel.org>; Mon, 07 Sep 2009 12:24:57 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4AA50A49.7010905@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 07, 2009 at 03:27:37PM +0200, Patrick McHardy wrote:
> Jarek Poplawski wrote:
...
> >> +static int mq_dump(struct Qdisc *sch, struct sk_buff *skb)
> >> +{
> >> +	struct net_device *dev = qdisc_dev(sch);
> >> +	struct Qdisc *qdisc;
> >> +	unsigned int ntx;
> >> +
> >> +	sch->q.qlen = 0;
> >> +	memset(&sch->bstats, 0, sizeof(sch->bstats));
> >> +	memset(&sch->qstats, 0, sizeof(sch->qstats));
> >> +
> >> +	for (ntx = 0; ntx < dev->num_tx_queues; ntx++) {
> >> +		qdisc = netdev_get_tx_queue(dev, ntx)->qdisc_sleeping;
> >> +		spin_lock_bh(qdisc_lock(qdisc));
> >> +		sch->q.qlen		+= qdisc->q.qlen;
> >> +		sch->bstats.bytes	+= qdisc->bstats.bytes;
> >> +		sch->bstats.packets	+= qdisc->bstats.packets;
> >> +		sch->qstats.qlen	+= qdisc->qstats.qlen;
> > 
> > Like in Christoph's case, we should probably use q.qlen instead.
> 
> Its done a few lines above. This simply sums up all members of qstats.

AFAICS these members are updated only in tc_fill_qdisc, starting from
the root, so they might be not up-to-date at the moment, unless I miss
something.

Jarek P.
