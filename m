From: Sathya Perla <sathya.perla@emulex.com>
Subject: [net-next PATCH 1/5] be2net: create RSS rings even in multi-channel configs
Date: Wed, 29 Aug 2012 12:07:40 +0530
Message-ID: <daa7bcf4-fdbc-4db2-873e-653e4ab9f274@exht1.ad.emulex.com>
References: <1346222264-20819-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:46266 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752770Ab2H2G4o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2012 02:56:44 -0400
In-Reply-To: <1346222264-20819-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes from commit df505e were incorrectly over-written by commit 10ef9ab.
Fixing the same.

Change log of the original fix:
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
index 90a903d8..d86d25c 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2176,8 +2176,7 @@ static uint be_num_rss_want(struct be_adapter *adapter)
 {
 	u32 num = 0;
 	if ((adapter->function_caps & BE_FUNCTION_CAPS_RSS) &&
-	     !sriov_want(adapter) && be_physfn(adapter) &&
-	     !be_is_mc(adapter)) {
+	     !sriov_want(adapter) && be_physfn(adapter)) {
 		num = (adapter->be3_native) ? BE3_MAX_RSS_QS : BE2_MAX_RSS_QS;
 		num = min_t(u32, num, (u32)netif_get_num_default_rss_queues());
 	}
-- 
1.7.4
