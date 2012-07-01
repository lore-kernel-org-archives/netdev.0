From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 11/11] be2net: set maximal number of default
 RSS queues
Date: Sun, 1 Jul 2012 16:19:00 +0300
Message-ID: <1341148740-7375-12-git-send-email-yuvalmin@broadcom.com>
References: <1341148740-7375-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Sathya Perla" <sathya.perla@emulex.com>,
	"Subbu Seetharaman" <subbu.seetharaman@emulex.com>,
	"Ajit Khaparde" <ajit.khaparde@emulex.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4176 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932372Ab2GANUv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Jul 2012 09:20:51 -0400
In-Reply-To: <1341148740-7375-1-git-send-email-yuvalmin@broadcom.com>
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
index edce7af..2141bd7 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2172,12 +2172,14 @@ static void be_msix_disable(struct be_adapter *adapter)
 
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
