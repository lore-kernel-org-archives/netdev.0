From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 2/6] be2net: fixes in ethtool selftest
Date: Sun, 20 Feb 2011 15:41:20 -0600
Message-ID: <20110220214120.GA13643@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:11619 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755061Ab1BTVlk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Feb 2011 16:41:40 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> add missing separator between items in ethtool self_test array
> fix reporting of test resluts when link is down and
  when selftest command fails.

From: Suresh R <suresh.reddy@emulex.com>
Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/benet/be_ethtool.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index 82a9a27..0833cbd 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -127,7 +127,7 @@ static const char et_self_tests[][ETH_GSTRING_LEN] = {
 	"MAC Loopback test",
 	"PHY Loopback test",
 	"External Loopback test",
-	"DDR DMA test"
+	"DDR DMA test",
 	"Link test"
 };
 
@@ -642,7 +642,8 @@ be_self_test(struct net_device *netdev, struct ethtool_test *test, u64 *data)
 				&qos_link_speed) != 0) {
 		test->flags |= ETH_TEST_FL_FAILED;
 		data[4] = -1;
-	} else if (mac_speed) {
+	} else if (!mac_speed) {
+		test->flags |= ETH_TEST_FL_FAILED;
 		data[4] = 1;
 	}
 }
-- 
1.7.1

