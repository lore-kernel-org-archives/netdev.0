From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH 2/2] ixgbe: fix select_queue management (v2)
Date: Fri, 20 Mar 2009 23:21:38 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.64.0903202319050.12360@ppwaskie-MOBL2.amr.corp.intel.com>
References: <20090319233404.6697768b@nehalam> <20090319233610.51fe4ee1@nehalam>
 <20090320091247.38326931@nehalam> <Pine.WNT.4.64.0903202033090.16644@ppwaskie-MOBL2.amr.corp.intel.com>
 <20090320214515.5af3a6f4@nehalam>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:45754 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752123AbZCUGVm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 02:21:42 -0400
In-Reply-To: <20090320214515.5af3a6f4@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 20 Mar 2009, Stephen Hemminger wrote:

> The default select queue function in the kernel is:
> 
> static struct netdev_queue *dev_pick_tx(struct net_device *dev,
> 					struct sk_buff *skb)
> {
> 	const struct net_device_ops *ops = dev->netdev_ops;
> 	u16 queue_index = 0;
> 
> 	if (ops->ndo_select_queue)
> 		queue_index = ops->ndo_select_queue(dev, skb);
> 	else if (dev->real_num_tx_queues > 1)
> 		queue_index = skb_tx_hash(dev, skb);
> 
> 	skb_set_queue_mapping(skb, queue_index);
> 	return netdev_get_tx_queue(dev, queue_index);
> }
> 
> So if driver (re)sets real_num_tx_queues to 1 then queue_index will always
> 0 and all traffic will go to one queue. This is the same as having your
> own select_queue function.

I see your point, but it is a hack in my opinion.  The device will have 8 
real Tx queues, not 1.  I'd much rather go with the original proposal, 
since if the code in dev_pick_tx() changed, it could silently break ixgbe.

-PJ Waskiewicz
