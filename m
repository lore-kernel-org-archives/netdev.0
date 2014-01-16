From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] bonding: only rely on arp packets if arp
 monitor is used
Date: Wed, 15 Jan 2014 21:53:47 -0800 (PST)
Message-ID: <20140115.215347.1878720836750527619.davem@davemloft.net>
References: <1389837916-5377-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45123 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957AbaAPFxs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 00:53:48 -0500
In-Reply-To: <1389837916-5377-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Thu, 16 Jan 2014 03:05:10 +0100

> Currently, if arp_validate is off (0), slave_last_rx() returns the
> slave->dev->last_rx, which is always updated on *any* packet received by
> slave, and not only arps. This means that, if the validation of arps is
> off, we're treating *any* incoming packet as a proof of slave being up, and
> not only arps.
> 
> This might seem logical at the first glance, however it can cause a lot of
> troubles and false-positives, one example would be:
> 
> The arp_ip_target is NOT accessible, however someone in the broadcast domain
> spams with any broadcast traffic. This way bonding will be tricked that the
> slave is still up (as in - can access arp_ip_target), while it's not.
> 
> The documentation for arp_validate also states that *ARPs* will (not) be
> validated if it's on/off, and that the arp monitoring works on arps as
> traffic generators.
> 
> Also, the net_device->last_rx is already used in a lot of drivers (even
> though the comment states to NOT do it :)), and it's also ugly to modify it
> from bonding.
> 
> So, to fix this, remove the last_rx from bonding, *always* call
> bond_arp_rcv() in slave's rx_handler (bond_handle_frame), and if we spot an
> arp there - update the slave->last_arp_rx - and use it instead of
> net_device->last_rx. Finally, rename slave_last_rx() to slave_last_arp_rx()
> to reflect the changes.
> 
> As the changes touch really sensitive parts, I've tried to split them as
> much as possible, for easier debugging/bisecting.
> 
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

This series looks really good, applied, thanks Veaceslav.
