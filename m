From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 11/13] bnx2x: Avoid using zero MAC
Date: Mon, 11 Mar 2013 17:17:51 +0200
Message-ID: <1363015073-25743-12-git-send-email-yuvalmin@broadcom.com>
References: <1363015073-25743-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3895 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752137Ab3CKQZ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Mar 2013 12:25:28 -0400
In-Reply-To: <1363015073-25743-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prevent bnx2x devices which are used mainly for storage from using zero
MAC addresses as their primary MAC address.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index f685d2e..e5662a1 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -10832,14 +10832,12 @@ static void bnx2x_get_cnic_mac_hwinfo(struct bnx2x *bp)
 			}
 		}
 
-		if (IS_MF_STORAGE_SD(bp))
-			/* Zero primary MAC configuration */
-			memset(bp->dev->dev_addr, 0, ETH_ALEN);
-
-		if (IS_MF_FCOE_AFEX(bp) || IS_MF_FCOE_SD(bp))
-			/* use FIP MAC as primary MAC */
+		/* If this is a storage-only interface, use SAN mac as
+		 * primary MAC. Notice that for SD this is already the case,
+		 * as the SAN mac was copied from the primary MAC.
+		 */
+		if (IS_MF_FCOE_AFEX(bp))
 			memcpy(bp->dev->dev_addr, fip_mac, ETH_ALEN);
-
 	} else {
 		val2 = SHMEM_RD(bp, dev_info.port_hw_config[port].
 				iscsi_mac_upper);
-- 
1.7.7.2
