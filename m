From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next 3/7] be2net: Fix ethtool self test for Lancer
Date: Wed, 25 Apr 2012 17:16:28 +0530
Message-ID: <83deaf55-3e2b-4460-9f37-6fdc3747fe51@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:29215 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759063Ab2DYLrl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 07:47:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lancer does not support DDR self test. Fix ethtool self test by
skipping this test for Lancer.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_ethtool.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index dc9f74c..0c6f06e 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -793,7 +793,7 @@ be_self_test(struct net_device *netdev, struct ethtool_test *test, u64 *data)
 		}
 	}
 
-	if (be_test_ddr_dma(adapter) != 0) {
+	if (!lancer_chip(adapter) && be_test_ddr_dma(adapter) != 0) {
 		data[3] = 1;
 		test->flags |= ETH_TEST_FL_FAILED;
 	}
-- 
1.6.0.2
