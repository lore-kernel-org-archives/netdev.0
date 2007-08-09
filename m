From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Subject: [PATCH] 3c59x: fix duplex configuration
Date: Thu, 9 Aug 2007 10:57:54 +0200
Message-ID: <20070809085754.GA29945@bayes.mathematik.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mb-tmp-ohtmvyyn.xreary.bet@gromit.dyndns.org,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from john.hrz.tu-chemnitz.de ([134.109.132.2]:53406 "EHLO
	john.hrz.tu-chemnitz.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751166AbXHIJch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 05:32:37 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A special sequence of ifconfig up/down and plug/unplug the cable
can break the duplex configuration of the driver.

Setting 
vp->mii.full_duplex = vp->full_duplex 
in vortex_up should fix this.

Addresses Bug 8575 3c59x duplex configuration broken
http://bugzilla.kernel.org/show_bug.cgi?id=8575

Cc: Martin Buck <mb-tmp-ohtmvyyn.xreary.bet@gromit.dyndns.org>
Signed-off-by: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
---
 drivers/net/3c59x.c |    1 +
 1 file changed, 1 insertion(+)

--- linux-2.6.23-rc2.orig/drivers/net/3c59x.c
+++ linux-2.6.23-rc2/drivers/net/3c59x.c
@@ -1555,6 +1555,7 @@ vortex_up(struct net_device *dev)
 		mii_reg1 = mdio_read(dev, vp->phys[0], MII_BMSR);
 		mii_reg5 = mdio_read(dev, vp->phys[0], MII_LPA);
 		vp->partner_flow_ctrl = ((mii_reg5 & 0x0400) != 0);
+		vp->mii.full_duplex = vp->full_duplex;
 
 		vortex_check_media(dev, 1);
 	}
