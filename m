From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [net-next-2.6 PATCH v7 2/2] net_sched: implement a root
 container qdisc sch_mqprio
Date: Sat, 8 Jan 2011 00:28:46 +0100
Message-ID: <20110107232846.GC2050@del.dom.local>
References: <20110107224543.19830.74009.stgit@jf-dev1-dcblab>
 <20110107224549.19830.3961.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, hadi@cyberus.ca, eric.dumazet@gmail.com,
	shemminger@vyatta.com, tgraf@infradead.org,
	bhutchings@solarflare.com, nhorman@tuxdriver.com,
	netdev@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:52294 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751470Ab1AGX2y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jan 2011 18:28:54 -0500
Received: by bwz15 with SMTP id 15so17754613bwz.19
        for <netdev@vger.kernel.org>; Fri, 07 Jan 2011 15:28:53 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20110107224549.19830.3961.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 07, 2011 at 02:45:49PM -0800, John Fastabend wrote:
> This implements a mqprio queueing discipline that by default creates
> a pfifo_fast qdisc per tx queue and provides the needed configuration
> interface.
> 
> Using the mqprio qdisc the number of tcs currently in use along
> with the range of queues alloted to each class can be configured. By
> default skbs are mapped to traffic classes using the skb priority.
> This mapping is configurable.
> 
> Configurable parameters,
> 
> struct tc_mqprio_qopt {
>         __u8    num_tc;
>         __u8    prio_tc_map[TC_BITMASK + 1];
>         __u8    hw;
>         __u16   count[TC_MAX_QUEUE];
>         __u16   offset[TC_MAX_QUEUE];
> };
> 
> Here the count/offset pairing give the queue alignment and the
> prio_tc_map gives the mapping from skb->priority to tc.
> 
> The hw bit determines if the hardware should configure the count
> and offset values. If the hardware bit is set then the operation
> will fail if the hardware does not implement the ndo_setup_tc
> operation. This is to avoid undetermined states where the hardware
> may or may not control the queue mapping. Also minimal bounds
> checking is done on the count/offset to verify a queue does not
> exceed num_tx_queues and that queue ranges do not overlap. Otherwise
> it is left to user policy or hardware configuration to create
> useful mappings.
> 
> It is expected that hardware QOS schemes can be implemented by
> creating appropriate mappings of queues in ndo_tc_setup().
> 
> One expected use case is drivers will use the ndo_setup_tc to map
> queue ranges onto 802.1Q traffic classes. This provides a generic
> mechanism to map network traffic onto these traffic classes and
> removes the need for lower layer drivers to know specifics about
> traffic types.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Acked-by: Jarek Poplawski <jarkao2@gmail.com>
