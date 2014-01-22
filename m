From: Chris Ruehl <chris.ruehl@gtsys.com.hk>
Subject: [PATCH 2/2] net: dm9000: Only call PHY reset for TYPE-B on shutdown
Date: Wed, 22 Jan 2014 11:20:13 +0800
Message-ID: <1390360813-29185-2-git-send-email-chris.ruehl@gtsys.com.hk>
References: <1390360813-29185-1-git-send-email-chris.ruehl@gtsys.com.hk>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	Chris Ruehl <chris.ruehl@gtsys.com.hk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.fpasia.hk ([202.130.89.98]:56881 "EHLO fpa01n0.fpasia.hk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753338AbaAVDU0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jan 2014 22:20:26 -0500
In-Reply-To: <1390360813-29185-1-git-send-email-chris.ruehl@gtsys.com.hk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unconditional call of PHY reset can triggers a fault to detect
the link for DM9000A on reboot, only a hard reset can solve it.
This patch check the version of the chip and call the PHY reset
only for the B version of the chip.

Signed-off-by: Chris Ruehl <chris.ruehl@gtsys.com.hk>
---
 drivers/net/ethernet/davicom/dm9000.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index 0349b91..55a2e9c 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -1333,7 +1333,8 @@ dm9000_shutdown(struct net_device *dev)
 	board_info_t *db = netdev_priv(dev);
 
 	/* RESET device */
-	dm9000_phy_write(dev, 0, MII_BMCR, BMCR_RESET);	/* PHY RESET */
+	if (db->type == TYPE_DM9000B)
+		dm9000_phy_write(dev, 0, MII_BMCR, BMCR_RESET);	/* PHY RESET */
 	iow(db, DM9000_GPR, 0x01);	/* Power-Down PHY */
 	iow(db, DM9000_IMR, IMR_PAR);	/* Disable all interrupt */
 	iow(db, DM9000_RCR, 0x00);	/* Disable RX */
-- 
1.7.10.4
