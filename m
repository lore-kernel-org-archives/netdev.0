From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [net-2.6 PATCH 7/10] Neterion: New driver: Main entry points
Date: Wed, 25 Mar 2009 19:26:28 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7705122717@nekter>
References: <1237968795.1655.271.camel@flash> <20090325083008.0179381d@nehalam>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>,
	"Netdev" <netdev@vger.kernel.org>,
	"Leonid Grossman" <Leonid.Grossman@neterion.com>
To: "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:31920 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753173AbZCYX0c convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 19:26:32 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20090325083008.0179381d@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen,
My replies are inline -

> Module parameters are a method of last resort. Module parameters are
> a pain for customers because they are hard to configure, and only work
> on one device driver. They should not be used if anything else is
> available.
[Ram] Agreed. The reason we have some of these options is due to
customer feedback who want the interface to come up on a boot with a
configuration that is different from the driver default. This may be a
feature that we could add to ethtool, by giving an option to change
driver configurations and persist over a boot.

> 
> Therefore the following can be replaced by existing ethtool hooks
> 	gro	    -> ethtool_get_gro, ethtool_set_gro
[Ram] Will change.
>         tx/rx_pause -> ethtool_get_pauseparm, ethtool_set_pauseparm
[Ram] We have an ethtool option already for this parameter but needed
the configuration to persist over a boot as noted above. Do you have a
suggestion to get around it?

> 
> I would like to see the following added to ethtool, go ahead and
propose
> some additions to ethtool that do what you need for addr_learn_en and
> tx_steering_type.
[Ram] Here's a proposal/wish list. Please let me know what you feel -

addr_len_en - enable/disable/query

tx_steering - 
	Steering options - mac + vlan id, priority, multi queue
	Configuration - enable/disable/query
Note: Ideally the same scheme needs to be used for both rx & tx but to
make this work for all nics, allow the steering option to be configured
independently for each direction.

Here is a list of other ethtool hooks required for IOV management. The
sysfs interface is ideal for the management but unfortunately is not
recommended for large amounts of data.

Get number of device mac addresses supported
Get number of device vlans supported
Get device vlan id table
Get device mac address table

Get number of virtual functions
Get virtual function stats
Get number of virtual function mac addresses
Get number of virtual function vlans
Get virtual function vlan id table
Get virtual function mac address table

> 
> Not sure what exec_mode does but why not call it 'debug'
[Ram] Yes, this is a debug option. When enabled, and if an error
condition occurs, the driver will mask all interrupts, not clear the
source of the alarm and gracefully stop all io's. A diagnostic dump of
registers and stats at this point reveals very useful information.

> 
> The intr_type parameter should be unnecessary, assuming the driver
does
> the right thing based on bus methods.  If you are worried about buggy
MSIX
> hardware, then please do a simulated irq to test IRQ routing.
[Ram]Will do. It was left for historical reasons in the event one may
encounter a buggy system.

> 
> Most drivers just use the NAPI weight to control the parameter you
> are setting with ring_indicate_max_pkts. The weight value is
changeable
> at runtime with sysfs.
[Ram] Agreed. Will make the change.

Thanks,
Ram
