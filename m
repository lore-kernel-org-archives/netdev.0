From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next-2.6 PATCH 1/4] net: implement mechanism for HW based
 QOS
Date: Fri, 17 Dec 2010 08:54:21 -0800
Message-ID: <4D0B95BD.3020003@intel.com>
References: <20101217153439.12170.39538.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hadi@cyberus.ca" <hadi@cyberus.ca>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:62375 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753465Ab0LQQyX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Dec 2010 11:54:23 -0500
In-Reply-To: <20101217153439.12170.39538.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/17/2010 7:34 AM, John Fastabend wrote:
> This patch provides a mechanism for lower layer devices to
> steer traffic using skb->priority to tx queues. This allows
> for hardware based QOS schemes to use the default qdisc without
> incurring the penalties related to global state and the qdisc
> lock. While reliably receiving skbs on the correct tx ring
> to avoid head of line blocking resulting from shuffling in
> the LLD. Finally, all the goodness from txq caching and xps/rps
> can still be leveraged.
> 
> Many drivers and hardware exist with the ability to implement
> QOS schemes in the hardware but currently these drivers tend
> to rely on firmware to reroute specific traffic, a driver
> specific select_queue or the queue_mapping action in the
> qdisc.
> 
> By using select_queue for this drivers need to be updated for
> each and every traffic type and we lose the goodness of much
> of the upstream work. Firmware solutions are inherently
> inflexible. And finally if admins are expected to build a
> qdisc and filter rules to steer traffic this requires knowledge
> of how the hardware is currently configured. The number of tx
> queues and the queue offsets may change depending on resources.
> Also this approach incurs all the overhead of a qdisc with filters.
> 
> With the mechanism in this patch users can set skb priority using
> expected methods ie setsockopt() or the stack can set the priority
> directly. Then the skb will be steered to the correct tx queues
> aligned with hardware QOS traffic classes. In the normal case with
> a single traffic class and all queues in this class everything
> works as is until the LLD enables multiple tcs.
> 
> To steer the skb we mask out the lower 4 bits of the priority
> and allow the hardware to configure upto 15 distinct classes
> of traffic. This is expected to be sufficient for most applications
> at any rate it is more then the 8021Q spec designates and is
> equal to the number of prio bands currently implemented in
> the default qdisc.
> 
> This in conjunction with a userspace application such as
> lldpad can be used to implement 8021Q transmission selection
> algorithms one of these algorithms being the extended transmission
> selection algorithm currently being used for DCB.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>

This conflicts with Vladislav Zolotarov's patch

[PATCH net-next 1/9] Take the distribution range definition out of skb_tx_hash()

The conflict is easily resolved, but I'll post a v2 of my patch to make it clean.

--John.
