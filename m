From: <sarveshwar.bandi@emulex.com>
Subject: [PATCH net-next 3/3] be2net: Avoid diagnostic test in certain versions of firmware to avoid NIC freeze.
Date: Fri, 26 Apr 2013 14:33:22 +0530
Message-ID: <b1c8d795-7103-4066-b3f2-9c6ebb3c640b@CMEXHTCAS1.ad.emulex.com>
References: <1366967002-26811-1-git-send-email-sarveshwar.bandi@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Suresh Reddy <suresh.reddy@emulex.com>,
	Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:26233 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932087Ab3DZJBn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Apr 2013 05:01:43 -0400
In-Reply-To: <1366967002-26811-1-git-send-email-sarveshwar.bandi@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Suresh Reddy <suresh.reddy@emulex.com>

Signed-off-by: Suresh Reddy <suresh.reddy@emulex.com>
Signed-off-by: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_ethtool.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index c4662db..ec3050b 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -755,6 +755,12 @@ be_self_test(struct net_device *netdev, struct ethtool_test *test, u64 *data)
 	int status;
 	u8 link_status = 0;
 
+	if (adapter->function_caps & BE_FUNCTION_CAPS_SUPER_NIC) {
+		dev_err(&adapter->pdev->dev, "Self test not supported\n");
+		test->flags |= ETH_TEST_FL_FAILED;
+		return;
+	}
+
 	memset(data, 0, sizeof(u64) * ETHTOOL_TESTS_NUM);
 
 	if (test->flags & ETH_TEST_FL_OFFLINE) {
-- 
1.7.9.5
