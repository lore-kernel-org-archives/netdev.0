From: Ben Dooks <ben@fluff.org>
Subject: ethtool locking
Date: Wed, 11 Jul 2007 11:58:08 +0100
Message-ID: <20070711105808.GC14086@fluff.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Linux netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:52765 "EHLO
	aeryn.fluff.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757811AbXGKK6J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 06:58:09 -0400
Received: from ben by aeryn.fluff.org.uk with local (Exim 4.63)
	(envelope-from <ben@fluff.org.uk>)
	id 1I8ZtY-00013A-7b
	for netdev@vger.kernel.org; Wed, 11 Jul 2007 11:58:08 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I am currently upgrading the DM9000 network driver to support
ethtool for items such as controlling the MII interface and
have the following question about locking with the ethtool
interface:

Most devices use an overall spinlock when changing the settings
such as in the 8139too.c driver:

static int rtl8139_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
{
	struct rtl8139_private *np = netdev_priv(dev);
	int rc;
	spin_lock_irq(&np->lock);
	rc = mii_ethtool_sset(&np->mii, cmd);
	spin_unlock_irq(&np->lock);
	return rc;
}

In the case of the DM9000, the phy read and write code
already has a spinlock in for hardware access.

Do I need any more locking for the MII calls other than
what is provided by the lower layer (IE, do these calls
need locking against anything else?)

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
