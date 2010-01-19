From: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Subject: [net-next PATCH 2/2] be2net: Add link test to list of ethtool self
 tests.
Date: Tue, 19 Jan 2010 20:45:36 +0530
Message-ID: <20100119151526.GA8267@serverengines.com>
Reply-To: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:33991 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754188Ab0ASPPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2010 10:15:36 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sarveshwar Bandi <sarveshwarb@serverengines.com>
---
 drivers/net/benet/be_ethtool.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index 2f2ebbd..09d8899 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -112,6 +112,7 @@ static const char et_self_tests[][ETH_GS
 	"PHY Loopback test",
 	"External Loopback test",
 	"DDR DMA test"
+	"Link test"
 };
 
 #define ETHTOOL_TESTS_NUM ARRAY_SIZE(et_self_tests)
@@ -529,6 +530,9 @@ static void
 be_self_test(struct net_device *netdev, struct ethtool_test *test, u64 *data)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
+	bool link_up;
+	u8 mac_speed = 0;
+	u16 qos_link_speed = 0;
 
 	memset(data, 0, sizeof(u64) * ETHTOOL_TESTS_NUM);
 
@@ -552,6 +556,13 @@ be_self_test(struct net_device *netdev, 
 		test->flags |= ETH_TEST_FL_FAILED;
 	}
 
+	if (be_cmd_link_status_query(adapter, &link_up, &mac_speed,
+				&qos_link_speed) != 0) {
+		test->flags |= ETH_TEST_FL_FAILED;
+		data[4] = -1;
+	} else if (mac_speed) {
+		data[4] = 1;
+	}
 }
 
 static int
-- 
1.4.0

