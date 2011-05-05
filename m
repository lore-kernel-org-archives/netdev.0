From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [net-next v3 3/6] bnx2x: Do storage mac address validation for
 SF mode.
Date: Thu, 5 May 2011 12:49:53 +0300
Message-ID: <1304588993.17528.3.camel@lb-tlvb-dmitry>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1466 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753254Ab1EEKAD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 May 2011 06:00:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_main.c |   32 ++++++++++++++++----------------
 1 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 259d1d9..32f9f7f 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -8571,15 +8571,6 @@ static void __devinit bnx2x_get_mac_hwinfo(struct bnx2x *bp)
 				BNX2X_DEV_INFO("Read iSCSI MAC: "
 					       "0x%x:0x%04x\n", val2, val);
 				bnx2x_set_mac_buf(iscsi_mac, val, val2);
-
-				/* Disable iSCSI OOO if MAC configuration is
-				 * invalid.
-				 */
-				if (!is_valid_ether_addr(iscsi_mac)) {
-					bp->flags |= NO_ISCSI_OOO_FLAG |
-						     NO_ISCSI_FLAG;
-					memset(iscsi_mac, 0, ETH_ALEN);
-				}
 			} else
 				bp->flags |= NO_ISCSI_OOO_FLAG | NO_ISCSI_FLAG;
 
@@ -8592,13 +8583,6 @@ static void __devinit bnx2x_get_mac_hwinfo(struct bnx2x *bp)
 					       "0x%x:0x%04x\n", val2, val);
 				bnx2x_set_mac_buf(fip_mac, val, val2);
 
-				/* Disable FCoE if MAC configuration is
-				 * invalid.
-				 */
-				if (!is_valid_ether_addr(fip_mac)) {
-					bp->flags |= NO_FCOE_FLAG;
-					memset(bp->fip_mac, 0, ETH_ALEN);
-				}
 			} else
 				bp->flags |= NO_FCOE_FLAG;
 		}
@@ -8629,6 +8613,22 @@ static void __devinit bnx2x_get_mac_hwinfo(struct bnx2x *bp)
 		else if (!IS_MF(bp))
 			memcpy(fip_mac, iscsi_mac, ETH_ALEN);
 	}
+
+	/* Disable iSCSI if MAC configuration is
+	 * invalid.
+	 */
+	if (!is_valid_ether_addr(iscsi_mac)) {
+		bp->flags |= NO_ISCSI_FLAG;
+		memset(iscsi_mac, 0, ETH_ALEN);
+	}
+
+	/* Disable FCoE if MAC configuration is
+	 * invalid.
+	 */
+	if (!is_valid_ether_addr(fip_mac)) {
+		bp->flags |= NO_FCOE_FLAG;
+		memset(bp->fip_mac, 0, ETH_ALEN);
+	}
 #endif
 }
 
-- 
1.7.2.2




