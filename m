From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [RFC net-next (v2) 13/14] be2net: set maximal number of default
 RSS queues
Date: Mon, 25 Jun 2012 14:45:44 +0300
Message-ID: <1340624745-8650-14-git-send-email-yuvalmin@broadcom.com>
References: <1340624745-8650-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Sathya Perla" <sathya.perla@emulex.com>,
	"Subbu Seetharaman" <subbu.seetharaman@emulex.com>,
	"Ajit Khaparde" <ajit.khaparde@emulex.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2786 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756064Ab2FYLsK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jun 2012 07:48:10 -0400
In-Reply-To: <1340624745-8650-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Cc: Sathya Perla <sathya.perla@emulex.com>
Cc: Subbu Seetharaman <subbu.seetharaman@emulex.com>
Cc: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 5a34503..a8564d0 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2142,12 +2142,14 @@ static void be_msix_disable(struct be_adapter *adapter)
 
 static uint be_num_rss_want(struct be_adapter *adapter)
 {
+	u32 num = 0;
 	if ((adapter->function_caps & BE_FUNCTION_CAPS_RSS) &&
 	     !sriov_want(adapter) && be_physfn(adapter) &&
-	     !be_is_mc(adapter))
-		return (adapter->be3_native) ? BE3_MAX_RSS_QS : BE2_MAX_RSS_QS;
-	else
-		return 0;
+	     !be_is_mc(adapter)) {
+		num = (adapter->be3_native) ? BE3_MAX_RSS_QS : BE2_MAX_RSS_QS;
+		num = min_t(u32, num, (u32)netif_get_num_default_rss_queues());
+	}
+	return num;
 }
 
 static void be_msix_enable(struct be_adapter *adapter)
-- 
1.7.9.rc2
