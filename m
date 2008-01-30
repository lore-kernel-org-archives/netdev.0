From: Bryan Wu <bryan.wu@analog.com>
Subject: [PATCH 6/8] [Blackfin] EMAC driver: add power down mode
Date: Wed, 30 Jan 2008 16:52:26 +0800
Message-ID: <1201683148-23931-7-git-send-email-bryan.wu@analog.com>
References: <1201683148-23931-1-git-send-email-bryan.wu@analog.com>
Cc: linux-kernel@vger.kernel.org,
	Vitja Makarov <vitja.makarov@gmail.com>,
	Bryan Wu <bryan.wu@analog.com>
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail10.analog.com ([137.71.25.55]:33791 "EHLO
	nwd2mail10.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755206AbYA3Iwi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 03:52:38 -0500
In-Reply-To: <1201683148-23931-1-git-send-email-bryan.wu@analog.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vitja Makarov <vitja.makarov@gmail.com>

This patch puts phy in power-down mode when interface is down.
Also we should think about energy detect power-down mode, that will
decrease power consumption when no link.

Signed-off-by: Vitja Makarov <vitja.makarov@gmail.com>
Signed-off-by: Bryan Wu <bryan.wu@analog.com>
---
 drivers/net/bfin_mac.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index e9bd059..f2368b7 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -884,10 +884,10 @@ static int bf537mac_open(struct net_device *dev)
 		return retval;
 
 	phy_start(lp->phydev);
+	phy_write(lp->phydev, MII_BMCR, BMCR_RESET);
 	setup_system_regs(dev);
 	bf537mac_disable();
 	bf537mac_enable();
-
 	pr_debug("hardware init finished\n");
 	netif_start_queue(dev);
 	netif_carrier_on(dev);
@@ -910,6 +910,7 @@ static int bf537mac_close(struct net_device *dev)
 	netif_carrier_off(dev);
 
 	phy_stop(lp->phydev);
+	phy_write(lp->phydev, MII_BMCR, BMCR_PDOWN);
 
 	/* clear everything */
 	bf537mac_shutdown(dev);
-- 
1.5.3.4
