From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: ethtool locking
Date: Wed, 11 Jul 2007 08:31:17 -0700
Message-ID: <20070711083117.46fdb9e2@freepuppy.rosehill.hemminger.net>
References: <20070711105808.GC14086@fluff.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux netdev <netdev@vger.kernel.org>
To: Ben Dooks <ben@fluff.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:41763 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753119AbXGKPcC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 11:32:02 -0400
In-Reply-To: <20070711105808.GC14086@fluff.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 11 Jul 2007 11:58:08 +0100
Ben Dooks <ben@fluff.org> wrote:

> I am currently upgrading the DM9000 network driver to support
> ethtool for items such as controlling the MII interface and
> have the following question about locking with the ethtool
> interface:
> 
> Most devices use an overall spinlock when changing the settings
> such as in the 8139too.c driver:
> 
> static int rtl8139_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
> {
> 	struct rtl8139_private *np = netdev_priv(dev);
> 	int rc;
> 	spin_lock_irq(&np->lock);
> 	rc = mii_ethtool_sset(&np->mii, cmd);
> 	spin_unlock_irq(&np->lock);
> 	return rc;
> }
> 
> In the case of the DM9000, the phy read and write code
> already has a spinlock in for hardware access.
> 
> Do I need any more locking for the MII calls other than
> what is provided by the lower layer (IE, do these calls
> need locking against anything else?)
> 

All network API changes are currently protected by the netlink
mutex (commonly referred to as RTNL). But your device must protect
itself from any changes in settings due to interrupts from PHY.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
