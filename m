From: "Vlad Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-next 3/5] bnx2x: Read FIP mac from SHMEM in single
 function mode
Date: Thu, 21 Jul 2011 20:57:52 +0300
Message-ID: <201107212057.52485.vladz@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3059 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751419Ab1GUR6U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jul 2011 13:58:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Read FIP MAC address from SHMEM's "port" section
similar to what we do in a MF mode when we read it from 
a "func" section of SHMEM.

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_main.c |   16 +++++++++-------
 1 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 121df1f..6ee9fc8 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -9251,6 +9251,12 @@ static void __devinit bnx2x_get_mac_hwinfo(struct bnx2x *bp)
 		val = SHMEM_RD(bp, dev_info.port_hw_config[port].
 				   iscsi_mac_lower);
 		bnx2x_set_mac_buf(iscsi_mac, val, val2);
+
+		val2 = SHMEM_RD(bp, dev_info.port_hw_config[port].
+				    fcoe_fip_mac_upper);
+		val = SHMEM_RD(bp, dev_info.port_hw_config[port].
+				   fcoe_fip_mac_lower);
+		bnx2x_set_mac_buf(fip_mac, val, val2);
 #endif
 	}
 
@@ -9258,13 +9264,9 @@ static void __devinit bnx2x_get_mac_hwinfo(struct bnx2x *bp)
 	memcpy(bp->dev->perm_addr, bp->dev->dev_addr, ETH_ALEN);
 
 #ifdef BCM_CNIC
-	/* Set the FCoE MAC in modes other then MF_SI */
-	if (!CHIP_IS_E1x(bp)) {
-		if (IS_MF_SD(bp))
-			memcpy(fip_mac, bp->dev->dev_addr, ETH_ALEN);
-		else if (!IS_MF(bp))
-			memcpy(fip_mac, iscsi_mac, ETH_ALEN);
-	}
+	/* Set the FCoE MAC in MF_SD mode */
+	if (!CHIP_IS_E1x(bp) && IS_MF_SD(bp))
+		memcpy(fip_mac, bp->dev->dev_addr, ETH_ALEN);
 
 	/* Disable iSCSI if MAC configuration is
 	 * invalid.
-- 
1.7.4.1


