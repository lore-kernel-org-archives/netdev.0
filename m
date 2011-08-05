From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 5/6] be2net: Disable RSS for VF interfaces
Date: Fri, 5 Aug 2011 15:00:56 -0500
Message-ID: <20110805200056.GA13608@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:2946 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756181Ab1HEUBO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2011 16:01:14 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Suresh Reddy <suresh.reddy@emulex.com>
Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/benet/be_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 1a3acca..c20e302 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1685,7 +1685,8 @@ static void be_rx_queues_destroy(struct be_adapter *adapter)
 static u32 be_num_rxqs_want(struct be_adapter *adapter)
 {
 	if ((adapter->function_caps & BE_FUNCTION_CAPS_RSS) &&
-		!adapter->sriov_enabled && !(adapter->function_mode & 0x400)) {
+		!adapter->sriov_enabled && !(adapter->function_mode & 0x400) &&
+		be_physfn(adapter)) {
 		return 1 + MAX_RSS_QS; /* one default non-RSS queue */
 	} else {
 		dev_warn(&adapter->pdev->dev,
-- 
1.7.4.1

