From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/4] bnx2: Fix logic to setup VLAN rx tagging.
Date: Thu, 14 Aug 2008 15:22:56 -0700
Message-ID: <1218752579-20506-2-git-send-email-mchan@broadcom.com>
References: <1218752579-20506-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>,
	"Matt Carlson" <mcarlson@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2530 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752123AbYHNWTS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2008 18:19:18 -0400
In-Reply-To: <1218752579-20506-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should now be checking BNX2_FLAG_CAN_KEEP_VLAN to determine how
to set the VLAN rx tagging in the RX_MODE register.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/bnx2.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 5ebde67..0623ceb 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -3237,10 +3237,10 @@ bnx2_set_rx_mode(struct net_device *dev)
 				  BNX2_EMAC_RX_MODE_KEEP_VLAN_TAG);
 	sort_mode = 1 | BNX2_RPM_SORT_USER0_BC_EN;
 #ifdef BCM_VLAN
-	if (!bp->vlgrp && !(bp->flags & BNX2_FLAG_ASF_ENABLE))
+	if (!bp->vlgrp && (bp->flags & BNX2_FLAG_CAN_KEEP_VLAN))
 		rx_mode |= BNX2_EMAC_RX_MODE_KEEP_VLAN_TAG;
 #else
-	if (!(bp->flags & BNX2_FLAG_ASF_ENABLE))
+	if (bp->flags & BNX2_FLAG_CAN_KEEP_VLAN)
 		rx_mode |= BNX2_EMAC_RX_MODE_KEEP_VLAN_TAG;
 #endif
 	if (dev->flags & IFF_PROMISC) {
-- 
1.5.6.GIT


