From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 25/34]bnx2x: Wrong HDR offset in CAM
Date: Wed, 14 Jan 2009 18:43:59 +0200
Message-ID: <1231951439.11301.146.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2683 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764026AbZANQox (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 11:44:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Has a negative side effect when sending MAC update with no content (as done in
the self-test)

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 5f0d2de..f97c4e0 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -6166,7 +6166,7 @@ static void bnx2x_set_mac_addr_e1(struct bnx2x *bp, int set)
 	 * multicast 64-127:port0 128-191:port1
 	 */
 	config->hdr.length_6b = 2;
-	config->hdr.offset = port ? 31 : 0;
+	config->hdr.offset = port ? 32 : 0;
 	config->hdr.client_id = BP_CL_ID(bp);
 	config->hdr.reserved1 = 0;
 
@@ -8945,7 +8945,10 @@ static int bnx2x_test_intr(struct bnx2x *bp)
 		return -ENODEV;
 
 	config->hdr.length_6b = 0;
-	config->hdr.offset = 0;
+	if (CHIP_IS_E1(bp))
+		config->hdr.offset = (BP_PORT(bp) ? 32 : 0);
+	else
+		config->hdr.offset = BP_FUNC(bp);
 	config->hdr.client_id = BP_CL_ID(bp);
 	config->hdr.reserved1 = 0;
 
@@ -9904,7 +9907,7 @@ static void bnx2x_set_rx_mode(struct net_device *dev)
 				for (; i < old; i++) {
 					if (CAM_IS_INVALID(config->
 							   config_table[i])) {
-						i--; /* already invalidated */
+						/* already invalidated */
 						break;
 					}
 					/* invalidate */
-- 
1.5.4.3




