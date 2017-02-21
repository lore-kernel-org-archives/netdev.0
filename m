From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] bnxt_en: use eth_hw_addr_random()
Date: Tue, 21 Feb 2017 15:27:28 +0100
Message-ID: <20170221142728.604-1-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org
To: Michael Chan <michael.chan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:49460 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753143AbdBUO1j (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 21 Feb 2017 09:27:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use eth_hw_addr_random() to set a random MAC address in order to make
sure bp->dev->addr_assign_type will be properly set to NET_ADDR_RANDOM.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 6dacdf1e4d26..235733e91c79 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4552,7 +4552,7 @@ static int bnxt_hwrm_func_qcaps(struct bnxt *bp)
 			/* overwrite netdev dev_adr with admin VF MAC */
 			memcpy(bp->dev->dev_addr, vf->mac_addr, ETH_ALEN);
 		} else {
-			random_ether_addr(bp->dev->dev_addr);
+			eth_hw_addr_random(bp->dev);
 			rc = bnxt_approve_mac(bp, bp->dev->dev_addr);
 		}
 		return rc;
-- 
2.11.0
