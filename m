From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 2/2] net: decreasing real_num_tx_queues needs
 to flush qdisc
Date: Fri, 02 Jul 2010 21:59:57 -0700 (PDT)
Message-ID: <20100702.215957.189703365.davem@davemloft.net>
References: <20100701232103.15685.48453.stgit@localhost.localdomain>
	<20100701232156.15685.69551.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	john.r.fastabend@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49004
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751544Ab0GCE7n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Jul 2010 00:59:43 -0400
In-Reply-To: <20100701232156.15685.69551.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 01 Jul 2010 16:21:57 -0700

> From: John Fastabend <john.r.fastabend@intel.com>
> 
> Reducing real_num_queues needs to flush the qdisc otherwise
> skbs with queue_mappings greater then real_num_tx_queues can
> be sent to the underlying driver.
> 
> The flow for this is,
> 
> dev_queue_xmit()
> 	dev_pick_tx()
> 		skb_tx_hash()  => hash using real_num_tx_queues
> 		skb_set_queue_mapping()
> 	...
> 	qdisc_enqueue_root() => enqueue skb on txq from hash
> ...
> dev->real_num_tx_queues -= n
> ...
> sch_direct_xmit()
> 	dev_hard_start_xmit()
> 		ndo_start_xmit(skb,dev) => skb queue set with old hash
> 
> skbs are enqueued on the qdisc with skb->queue_mapping set
> 0 < queue_mappings < real_num_tx_queues.  When the driver
> decreases real_num_tx_queues skb's may be dequeued from the
> qdisc with a queue_mapping greater then real_num_tx_queues.
> 
> This fixes a case in ixgbe where this was occurring with DCB
> and FCoE. Because the driver is using queue_mapping to map
> skbs to tx descriptor rings we can potentially map skbs to
> rings that no longer exist.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> Tested-by: Ross Brattain <ross.b.brattain@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
