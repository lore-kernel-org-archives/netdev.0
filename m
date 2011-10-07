From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 1/2 net] r6040: invoke phy_{start,stop} when appropriate
Date: Fri, 7 Oct 2011 11:40:17 +0200
Message-ID: <201110071140.17299.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:62926 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759711Ab1JGJkX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 05:40:23 -0400
Received: by wyg34 with SMTP id 34so3693227wyg.19
        for <netdev@vger.kernel.org>; Fri, 07 Oct 2011 02:40:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe reported to me that right after a bring up of a r6040 interface
the ethtool output had no consistent output with respect to link duplex
and speed. Fix this by adding a missing phy_start call in r6040_up and
conversely a phy_stop call in r6040_down to properly initialize phy states.

Reported-by: Joe Chou <Joe.Chou@rdc.com.tw>
Signed-off-by: Florian Fainelli <florian@openwrt.org>
CC: stable@kernel.org # 2.6.38+
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index b64fcee..ab59538 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -470,6 +470,8 @@ static void r6040_down(struct net_device *dev)
 	iowrite16(adrp[0], ioaddr + MID_0L);
 	iowrite16(adrp[1], ioaddr + MID_0M);
 	iowrite16(adrp[2], ioaddr + MID_0H);
+
+	phy_stop(lp->phydev);
 }
 
 static int r6040_close(struct net_device *dev)
@@ -727,6 +729,8 @@ static int r6040_up(struct net_device *dev)
 	/* Initialize all MAC registers */
 	r6040_init_mac_regs(dev);
 
+	phy_start(lp->phydev);
+
 	return 0;
 }
 
-- 
1.7.4.1
