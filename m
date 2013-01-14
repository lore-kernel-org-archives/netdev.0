From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 03/10] bnx2x: use SAN Mac for FCoE.
Date: Mon, 14 Jan 2013 17:11:43 +0200
Message-ID: <1358176310-31504-4-git-send-email-yuvalmin@broadcom.com>
References: <1358176310-31504-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4314 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757248Ab3ANQKA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2013 11:10:00 -0500
In-Reply-To: <1358176310-31504-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

Current logic causes chips running in switch dependent multi-function
FCoE mode not to configure their MAC, leading to an all 0s MAC.

This patch configures the interface with the SAN Mac instead.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 13e5db6..7233946 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -10745,7 +10745,7 @@ static void bnx2x_get_cnic_mac_hwinfo(struct bnx2x *bp)
 			/* Zero primary MAC configuration */
 			memset(bp->dev->dev_addr, 0, ETH_ALEN);
 
-		if (IS_MF_FCOE_AFEX(bp))
+		if (IS_MF_FCOE_AFEX(bp) || IS_MF_FCOE_SD(bp))
 			/* use FIP MAC as primary MAC */
 			memcpy(bp->dev->dev_addr, fip_mac, ETH_ALEN);
 
-- 
1.8.1.227.g44fe835
