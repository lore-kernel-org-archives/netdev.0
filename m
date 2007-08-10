From: akpm@linux-foundation.org
Subject: [patch 17/18] 3c59x: fix duplex configuration
Date: Fri, 10 Aug 2007 14:05:26 -0700
Message-ID: <200708102105.l7AL5Q2h008995@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	klassert@mathematik.tu-chemnitz.de,
	mb-tmp-ohtmvyyn.xreary.bet@gromit.dyndns.org, protasnb@gmail.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:35380 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751028AbXHJVQw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 17:16:52 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>

A special sequence of ifconfig up/down and plug/unplug the cable can break
the duplex configuration of the driver.

Setting
vp->mii.full_duplex = vp->full_duplex
in vortex_up should fix this.

Addresses Bug 8575 3c59x duplex configuration broken
http://bugzilla.kernel.org/show_bug.cgi?id=8575

Cc: Martin Buck <mb-tmp-ohtmvyyn.xreary.bet@gromit.dyndns.org>
Signed-off-by: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Cc: Natalie Protasevich <protasnb@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/3c59x.c |    1 +
 1 files changed, 1 insertion(+)

diff -puN drivers/net/3c59x.c~3c59x-fix-duplex-configuration drivers/net/3c59x.c
--- a/drivers/net/3c59x.c~3c59x-fix-duplex-configuration
+++ a/drivers/net/3c59x.c
@@ -1559,6 +1559,7 @@ vortex_up(struct net_device *dev)
 		mii_reg1 = mdio_read(dev, vp->phys[0], MII_BMSR);
 		mii_reg5 = mdio_read(dev, vp->phys[0], MII_LPA);
 		vp->partner_flow_ctrl = ((mii_reg5 & 0x0400) != 0);
+		vp->mii.full_duplex = vp->full_duplex;
 
 		vortex_check_media(dev, 1);
 	}
_
