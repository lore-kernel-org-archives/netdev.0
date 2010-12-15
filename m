From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC PATCH v1] iproute2: add IFLA_TC support to 'ip link'
Date: Wed, 15 Dec 2010 08:19:48 -0500
Message-ID: <1292419188.2067.27.camel@mojatatu>
References: <20101201182758.3297.34345.stgit@jf-dev1-dcblab>
	 <1291286428.2183.494.camel@mojatatu>  <4CF7F8B4.4060807@intel.com>
	 <1291374412.10126.17.camel@mojatatu>  <4D0134CC.8070605@intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "shemminger@vyatta.com" <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f180.google.com ([209.85.161.180]:44885 "EHLO
	mail-gx0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752076Ab0LONTx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 08:19:53 -0500
Received: by gxk19 with SMTP id 19so1245746gxk.11
        for <netdev@vger.kernel.org>; Wed, 15 Dec 2010 05:19:52 -0800 (PST)
In-Reply-To: <4D0134CC.8070605@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for the latency.

On Thu, 2010-12-09 at 11:58 -0800, John Fastabend wrote:

> I think what we really want is a container to create groups of tx queues 
> which can then be managed and given a scheduler. One reason for this is 
> the 802.1Q spec allows for different schedulers to be running on different
> traffic classes including vendor specific schedulers. So having a root 
> "hardware-kinda-8021q-sched" doesn't seem flexible enough to handle 
> adding/removing schedulers per traffic class.
> 
> With a container qdisc statistics roll up nicely as expected and 
> the default scheduler can be the usual mq qdisc.

As far as i can see the "container" is a qdisc. The noun doesnt
matter, mq looks sufficient.
[I just said "hardware-kinda-8021q-sched" because what you posted didnt
look 8012q conformant.]
 
> A first take at this coming shortly. Any thoughts?

Havent had time to look at patches you posted.

> > Ok, so you can do rate control as well?
> 
> Yes, but per tx_ring. So software needs to then balance the rings into
> an aggregated rate limiter. Using the container scheme I imagine a root 
> mclass qdisc with multiple "sch_rate_limiter" qdiscs. This qdisc could 
> manage the individual rate limiters per queue and get something like a 
> rate limiter per groups of tx queues.
> 

The qdisc semantics allow for hierachies i.e you could have qdiscs that
hold other qdiscs that each hold different scheduling algorithms etc.

> Yes this is how I would expect this to work. The prio mapping is configurable
> so I think this could be worked around by policy in tc. iproute2 would need 
> to pick a reasonable default mapping.
> 
> Warning thinking out loud here but maybe we could also add a qdisc op to pick 
> the underlying tx queue basically a qdisc ops for dev_pick_tx(). This ops could 
> be part of the root qdisc and called in dev_queue_xmit(). I would need to think 
> about this some more to see if it is sane but bottom line is the tx queue needs 
> to be learned before __dev_xmit_skb(). The default mechanism in this patch set 
> being the skb prio.
> 

You could use the qdisc major:minor to map to the hardware level queues.
But care is needed so that the user doesnt choose the wrong mapping, out
of boundary mapping etc. I am sure such validation can be done at
iproute2 level way before the hardware is configured.

cheers,
jamal

