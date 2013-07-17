From: <Narendra_K@Dell.com>
Subject: RE: [patch net-next RFC 3/3] net: export physical port id via sysfs
Date: Thu, 18 Jul 2013 01:09:41 +0530
Message-ID: <E31FB011129F30488D5861F383904915210EF3F968@BLRX7MCDC201.AMER.DELL.COM>
References: <1373908027-25800-1-git-send-email-jiri@resnulli.us>
 <1373908027-25800-4-git-send-email-jiri@resnulli.us>
 <E31FB011129F30488D5861F383904915210EF3F51F@BLRX7MCDC201.AMER.DELL.COM>
 <20130717082949.GA1582@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <bhutchings@solarflare.com>,
	<john.r.fastabend@intel.com>
To: <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausxipps301.us.dell.com ([143.166.148.223]:52331 "EHLO
	ausxipps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756246Ab3GQTjx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jul 2013 15:39:53 -0400
In-Reply-To: <20130717082949.GA1582@minipsycho.orion>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Jiri Pirko [mailto:jiri@resnulli.us]
> Sent: Wednesday, July 17, 2013 2:00 PM
> To: K, Narendra
> Cc: netdev@vger.kernel.org; bhutchings@solarflare.com;
> john.r.fastabend@intel.com
> Subject: Re: [patch net-next RFC 3/3] net: export physical port id via sysfs
> 
> Tue, Jul 16, 2013 at 10:03:04PM CEST, Narendra_K@Dell.com wrote:
[...] 
> >> +static ssize_t show_phys_port_id(struct device *dev,
> >> +				 struct device_attribute *attr, char *buf) {
> >> +	struct net_device *netdev = to_net_dev(dev);
> >> +	ssize_t ret = 0;
> >> +
> >> +	if (!rtnl_trylock())
> >> +		return restart_syscall();
> >> +
> >> +	if (dev_isalive(netdev) && netdev->netdev_ops-
> >> >ndo_get_phys_port_id) {
> >> +		struct netdev_phys_port_id ppid;
> >> +
> >> +		ret = netdev->netdev_ops->ndo_get_phys_port_id(netdev,
> >> &ppid);
> >[>]
> >
> >Hello,
> >I am thinking if "ndo_get_phys_port_id()" is required.  With it, the driver
> needs to generate port_id  every time "ndo_get_phys_port_id()" is called,
> but the "netdev->phys_port.port_id" might not have changed.  If 'phys_port'
> structure is part of 'struct net_device',  then 'netdev->phys_port.port_id'
> and port_id_len are set by driver before calling 'register_netdev' and are
> available to the core.  Driver not implementing it would indicate it by a
> "port_id_len" of zero.     If the "netdev->phys_port.port_id" changes for
> some reason then the notification sent by the driver would ensure that the
> interested kernel components and user space are notified of the change.
> 
> Although this can be done by extending netdevice structure by another item,
> I believe it is cleaner to do it by ndo. Driver has a flexibility to either compute
> the phys port on fly of compute it once, store it in it's private data and use it
> when ndo is called.

It seems to me that phys_port identifier is a net_device property,  similar to netdev->dev_addr or netdev->if_port, and could be part of struct net_device  as discussed in [1].  My understanding may not be correct.

Hello Ben,  for the hybrid guest networking scenario, would it be required/helpful for phys_port to be part of net_device structure or either of the approaches would be fine.

With regards,
Narendra K
Linux Engineering
Dell Inc.

[1] http://marc.info/?l=linux-netdev&m=136920998009209&w=2
