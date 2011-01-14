From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] CHOKe flow scheduler (0.8)
Date: Fri, 14 Jan 2011 14:55:14 +0100
Message-ID: <4D3055C2.3060807@trash.net>
References: <20110113092706.154748c2@s6510>	<1294951069.3403.11.camel@edumazet-laptop> <20110113153436.70d3c0a3@s6510> <4D305598.1010207@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35731 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756794Ab1ANNzK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 08:55:10 -0500
In-Reply-To: <4D305598.1010207@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14.01.2011 14:54, Patrick McHardy wrote:
> On 14.01.2011 00:34, Stephen Hemminger wrote:
>> +static int choke_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>> +{
>> ...
>> +	/* Is queue small? */
>> +	if (p->qavg <= p->qth_min)
>> +		p->qcount = -1;
>> +	else {
>> +		struct sk_buff *oskb;
>> +		unsigned int idx;
>> +
>> +		/* Draw a packet at random from queue */
>> +		oskb = choke_peek_random(sch, &idx);
>> +
>> +		/* Both packets from same flow ? */
>> +		if (*(unsigned int *)(qdisc_skb_cb(oskb)->data) == hash) {
>> +			/* Drop both packets */
>> +			q->stats.matched++;
>> +			choke_drop_by_idx(q, idx);
>> +			sch->qstats.backlog -= qdisc_pkt_len(skb);
>> +			--sch->q.qlen;
>> +			qdisc_drop(oskb, sch);
> 
> You need to adjust the qlen values of parent qdiscs by calling
> qdisc_tree_decrease_qlen(), they are not aware that a second
> packet has been dropped.

I just saw that Eric already fixed this :)
