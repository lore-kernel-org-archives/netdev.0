From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 7/8] infiniband: driver API update
Date: Mon, 05 Jan 2009 13:02:15 -0800
Message-ID: <adawsd9mppk.fsf@cisco.com>
References: <20090105201442.749889072@vyatta.com>
	<20090105201514.828840735@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Roland Dreier <rolandd@cisco.com>,
	Sean Hefty <sean.hefty@intel.com>,
	Hal Rosenstock <hal.rosenstock@gmail.com>,
	netdev@vger.kernel.org, general@lists.openfabrics.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:59364 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753117AbZAEVCR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2009 16:02:17 -0500
In-Reply-To: <20090105201514.828840735@vyatta.com> (Stephen Hemminger's
	message of "Mon, 05 Jan 2009 12:14:49 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks good enough, so Dave if you want to merge it, you can add

Acked-by: Roland Dreier <rolandd@cisco.com>

or let me know if you want me to pull it in through my tree.  A couple
of nits that are probably not worth fixing.  First, globally, it might
be slightly nicer to merge this as one patch per module, rather than all
lumped together.  And also:

 > +static const struct net_device_ops c2_netdev_ops = {
 > +	.ndo_open       = c2_pseudo_up,
 > +	.ndo_stop       = c2_pseudo_down,
 > +	.ndo_start_xmit = c2_pseudo_xmit_frame,
 > +	.ndo_change_mtu = c2_pseudo_change_mtu,
 > +};
 > +
 > +

would have preferred only one empty line here.

 > @@ -735,7 +737,6 @@ static void setup(struct net_device *net
 >  	netdev->addr_len = ETH_ALEN;
 >  	netdev->tx_queue_len = 0;
 >  	netdev->flags |= IFF_NOARP;
 > -	return;
 >  }
 >  
 >  static struct net_device *c2_pseudo_netdev_init(struct c2_dev *c2dev)

would preferred to leave out unrelated changes.

 > +static const struct net_device_ops nes_netdev_ops = {
 > +	.ndo_open		= nes_netdev_open,
 > +	.ndo_stop		= nes_netdev_stop,
 > +	.ndo_start_xmit		= nes_netdev_start_xmit,
 > +	.ndo_get_stats		= nes_netdev_get_stats,
 > +	.ndo_tx_timeout		= nes_netdev_tx_timeout,
 > +	.ndo_validate_addr	= eth_validate_addr,
 > +	.ndo_set_mac_address	= nes_netdev_set_mac_address,
 > +	.ndo_set_multicast_list = nes_netdev_set_multicast_list,
 > +	.ndo_change_mtu 	= nes_netdev_change_mtu,
 > +	.ndo_vlan_rx_register   = nes_netdev_vlan_rx_register,
 > +};
 > +
 >  
 >  /**

extra blank line here too.

 - R.
