From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH] be2net: create RSS rings even in multi-channel configs
Date: Fri, 20 Jan 2012 12:04:04 +0530
Message-ID: <1327041244-427-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:50004 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750825Ab2ATGk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2012 01:40:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently RSS rings are not created in a multi-channel config.
RSS rings can be created on one (out of four) interfaces per port in a
multi-channel config. Doing this insulates the driver from a FW bug wherin
multi-channel config is wrongly reported even when not enabled. This also
helps performance in a multi-channel config, as one interface per port gets
RSS rings.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 6c46753..dfe748e 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1786,8 +1786,7 @@ static void be_rx_queues_destroy(struct be_adapter *adapter)
 static u32 be_num_rxqs_want(struct be_adapter *adapter)
 {
 	if ((adapter->function_caps & BE_FUNCTION_CAPS_RSS) &&
-	     !sriov_enabled(adapter) && be_physfn(adapter) &&
-	     !be_is_mc(adapter)) {
+	     !sriov_enabled(adapter) && be_physfn(adapter)) {
 		return 1 + MAX_RSS_QS; /* one default non-RSS queue */
 	} else {
 		dev_warn(&adapter->pdev->dev,
-- 
1.7.4
