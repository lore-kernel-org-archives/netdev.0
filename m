From: "Yaniv Rosner" <yaniv.rosner@broadcom.com>
Subject: [PATCH net-next 3/8] bnx2x: Reset link before any new link
 settings
Date: Wed, 1 Sep 2010 22:51:23 +0300
Message-ID: <1283370683.4403.134.camel@lb-tlvb-yanivr.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1335 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755427Ab0IAQdM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Sep 2010 12:33:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reset link before any new link settings to avoid potential link issue
caused by previous link settings 

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 7fb9a61..b09fa04 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -1292,6 +1292,7 @@ void bnx2x_link_set(struct bnx2x *bp)
 {
 	if (!BP_NOMCP(bp)) {
 		bnx2x_acquire_phy_lock(bp);
+		bnx2x_link_reset(&bp->link_params, &bp->link_vars, 1);
 		bnx2x_phy_init(&bp->link_params, &bp->link_vars);
 		bnx2x_release_phy_lock(bp);
 
-- 
1.7.1




