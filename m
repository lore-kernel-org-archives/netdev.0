From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/3] vlan: adds vlan_dev_select_queue
Date: Wed, 17 Feb 2010 13:43:30 -0800 (PST)
Message-ID: <20100217.134330.48386140.davem@davemloft.net>
References: <20100217123606.18210.13602.stgit@localhost.localdomain>
	<1266414675.3246.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, vasu.dev@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57270
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754917Ab0BQVnO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 16:43:14 -0500
In-Reply-To: <1266414675.3246.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 17 Feb 2010 14:51:15 +0100

> This is a bit dangerous and deserves a self contained patch IMHO.
> 
> I would add for example a
> 	BUG_ON(vlandev->real_num_tx_queues > vlandev->num_tx_queues)
> 
> ------------------
> 
> For performance reason, we could avoid calling vlan_dev_select_queue()
> for real devices without ndo_select_queue() handler, this would need to
> mirror vlan_netdev_ops & vlan_netdev_accel_ops.
> 
> It would also make vlan_dev_select_queue shorter and not duplicates
> internals of net/dev/core.c :
> 
> static u16 vlan_dev_select_queue(struct net_device *dev, struct sk_buff
> *skb)
> {
>        struct net_device *rdev = vlan_dev_info(dev)->real_dev;
>        const struct net_device_ops *ops = rdev->netdev_ops;
> 
>        return ops->ndo_select_queue(rdev, skb);
> }
> 
> 

Jeff, please resubmit this patch set after addressing
Eric's feedback.

Thanks!
