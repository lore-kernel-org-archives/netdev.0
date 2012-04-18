From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] bonding,vlan: propagate MAC failover changes
 to VLANs
Date: Wed, 18 Apr 2012 19:17:59 +0100
Message-ID: <1334773079.2426.32.camel@bwh-desktop.uk.solarflarecom.com>
References: <10757.1334772163@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Andy Gospodarek <andy@greyhouse.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:31619 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753087Ab2DRSSE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 14:18:04 -0400
In-Reply-To: <10757.1334772163@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-04-18 at 11:02 -0700, Jay Vosburgh wrote:
> 	With bonding's fail_over_mac=active, during failover the MAC
> address of the bond itself changes to match that of the slave.
> 
> 	This patch adds a notifier call to cause VLANs stacked atop the
> bonding to also change their MAC addresses to the new address when a
> failover occurs.
> 
> 	While it is legal for a VLAN to have a MAC address that differs
> from the underlying device, at least one device (qeth) that requires the
> use of fail_over_mac for bonding cannot handle the VLAN's MAC differing
> from that of the bond; thus, it needs the MAC change to propagate up
> to any VLANs when fail_over_mac is set to active.
[...]

This doesn't make sense to me.  You're applying the behaviour to all
VLANs on top of a bond, whether or not the underlying device is driven
by qeth, and ignoring any MAC address changes that don't involve the
bonding driver.

I think either of these would be better fixes:
1. Make VLAN devices follow changes to the parent device's MAC address
unless they are assigned an address of their own.
2. Add a configuration flag for VLAN devices to follow changes to the
parent device's MAC address.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
