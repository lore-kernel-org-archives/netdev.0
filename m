From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH] bnx2x: Initialize cnic status block during chip reset
Date: Wed, 23 Dec 2009 16:02:45 +0200
Message-ID: <1261576965.15524.42.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Michael Chan" <mchan@broadcom.com>, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4737 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753345AbZLWOCk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2009 09:02:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <mchan@broadcom.com>

When the device is reset during MTU change, ring size change, or self
test, etc, the cnic status block needs to be properly initialized if
cnic is registered.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 77ba135..306c2b8 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -7593,6 +7593,8 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 		if (bp->cnic_eth_dev.drv_state & CNIC_DRV_STATE_REGD) {
 			bnx2x_set_iscsi_eth_mac_addr(bp, 1);
 			bp->cnic_flags |= BNX2X_CNIC_FLAG_MAC_SET;
+			bnx2x_init_sb(bp, bp->cnic_sb, bp->cnic_sb_mapping,
+				      CNIC_SB_ID(bp));
 		}
 		mutex_unlock(&bp->cnic_mutex);
 #endif
-- 
1.5.4.3




