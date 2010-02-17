From: Vasu Dev <vasu.dev@linux.intel.com>
Subject: Re: [net-next-2.6 PATCH 1/3] vlan: adds vlan_dev_select_queue
Date: Wed, 17 Feb 2010 14:40:41 -0800
Message-ID: <1266446441.1891.96.camel@vi2.jf.intel.com>
References: <20100217123606.18210.13602.stgit@localhost.localdomain>
	 <1266414675.3246.12.camel@edumazet-laptop>
	 <20100217.134330.48386140.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, vasu.dev@intel.com
To: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:54700 "EHLO
	azsmga101.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752819Ab0BQWkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 17:40:43 -0500
In-Reply-To: <20100217.134330.48386140.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-02-17 at 13:43 -0800, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 17 Feb 2010 14:51:15 +0100
> 
> > This is a bit dangerous and deserves a self contained patch IMHO.
> > 

OK, I'll create separate patch for this.
 
> > I would add for example a
> > 	BUG_ON(vlandev->real_num_tx_queues > vlandev->num_tx_queues)
> > 

I'll add this.

> > ------------------
> > 
> > For performance reason, we could avoid calling vlan_dev_select_queue()
> > for real devices without ndo_select_queue() handler, this would need to
> > mirror vlan_netdev_ops & vlan_netdev_accel_ops.
> > 

This means vlan_netdev_ops & vlan_netdev_accel_ops not to be const
anymore so that vlan_dev_select_queue() could be initialized to vlan ops
based on real dev ndo_select_queue() present or not, should be okay to
be not const anymore. I'll update patch as suggested.

> > It would also make vlan_dev_select_queue shorter and not duplicates
> > internals of net/dev/core.c :
> > 

Good reasons.

> > static u16 vlan_dev_select_queue(struct net_device *dev, struct sk_buff
> > *skb)
> > {
> >        struct net_device *rdev = vlan_dev_info(dev)->real_dev;
> >        const struct net_device_ops *ops = rdev->netdev_ops;
> > 
> >        return ops->ndo_select_queue(rdev, skb);
> > }
> > 
> > 
> 
> Jeff, please resubmit this patch set after addressing
> Eric's feedback.
> 

I'm updating patches per Eric's feedback to have Jeff resubmit these
patches.

	Vasu


