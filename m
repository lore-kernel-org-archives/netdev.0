From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/8] dsa: convert to net_device_ops
Date: Tue, 06 Jan 2009 10:43:44 -0800 (PST)
Message-ID: <20090106.104344.130715147.davem@davemloft.net>
References: <20090105201442.749889072@vyatta.com>
	<20090105201514.550766759@vyatta.com>
	<20090106060705.GG4414@server.marvell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: buytenh@marvell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34939
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750988AbZAFSnn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2009 13:43:43 -0500
In-Reply-To: <20090106060705.GG4414@server.marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@marvell.com>
Date: Mon, 5 Jan 2009 22:07:05 -0800

> On Mon, Jan 05, 2009 at 12:14:46PM -0800, Stephen Hemminger wrote:
> 
> > -	slave_dev->open = dsa_slave_open;
> > -	slave_dev->stop = dsa_slave_close;
> > -	slave_dev->change_rx_flags = dsa_slave_change_rx_flags;
> > -	slave_dev->set_rx_mode = dsa_slave_set_rx_mode;
> > -	slave_dev->set_multicast_list = dsa_slave_set_rx_mode;
> > -	slave_dev->set_mac_address = dsa_slave_set_mac_address;
> > -	slave_dev->do_ioctl = dsa_slave_ioctl;
> > +	slave_dev->netdev_ops = &dsa_netdev_ops;
> >  	SET_NETDEV_DEV(slave_dev, parent);
> >  	slave_dev->vlan_features = master->vlan_features;
> 
> Can you make three separate sets of netdevice ops, one for each of the
> tagging formats?  On the platforms this driver is used, packet forwarding
> performance matters a _lot_, and I'm pretty sure that adding an extra
> function call indirection in the TX path will translate to a directly
> measurable performance loss.

Agreed, that's probably the way this should be handled.

I'll drop this patch while this issue is being worked out.
