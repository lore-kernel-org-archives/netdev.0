From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net 1/2] bnx2x: correct reading of speed capabilities
Date: Wed, 1 May 2013 17:27:57 +0300
Message-ID: <1367418478-7416-2-git-send-email-yuvalmin@broadcom.com>
References: <1367418478-7416-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2569 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761469Ab3EAP2Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 May 2013 11:28:24 -0400
In-Reply-To: <1367418478-7416-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yaniv Rosner <yanivr@broadcom.com>

When the bnx2x driver reads the port configuration - mask irrelevant bits. 

Without this change, the unintended bits may cause the driver to needlessly
toggle the link, as a comparison in the link flap avoidance flow will show
that the old link did not advertise the same capabilities and thus cannot
be retained.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index a8f1ee3..9cc39f1 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -10575,10 +10575,12 @@ static void bnx2x_get_port_hwinfo(struct bnx2x *bp)
 
 	bp->link_params.speed_cap_mask[0] =
 		SHMEM_RD(bp,
-			 dev_info.port_hw_config[port].speed_capability_mask);
+			 dev_info.port_hw_config[port].speed_capability_mask) &
+		PORT_HW_CFG_SPEED_CAPABILITY_D0_MASK;
 	bp->link_params.speed_cap_mask[1] =
 		SHMEM_RD(bp,
-			 dev_info.port_hw_config[port].speed_capability_mask2);
+			 dev_info.port_hw_config[port].speed_capability_mask2) &
+		PORT_HW_CFG_SPEED_CAPABILITY_D0_MASK;
 	bp->port.link_config[0] =
 		SHMEM_RD(bp, dev_info.port_feature_config[port].link_config);
 
-- 
1.8.1.227.g44fe835
