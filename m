From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 05/13] e1000: Explicitly power up the PHY during loopback testing.
Date: Wed, 16 Aug 2006 14:56:26 -0700
Message-ID: <20060816215626.27080.6069.stgit@gitlost.site>
References: <20060816215336.27080.56147.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:58121 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932255AbWHPVsi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 17:48:38 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060816215336.27080.56147.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_ethtool.c |    7 +++++++
 drivers/net/e1000/e1000_main.c    |    2 +-
 2 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index 88a82ba..8edbc6b 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -1590,6 +1590,8 @@ e1000_diag_test_count(struct net_device 
 	return E1000_TEST_LEN;
 }
 
+extern void e1000_power_up_phy(struct e1000_adapter *);
+
 static void
 e1000_diag_test(struct net_device *netdev,
 		   struct ethtool_test *eth_test, uint64_t *data)
@@ -1606,6 +1608,8 @@ e1000_diag_test(struct net_device *netde
 		uint8_t forced_speed_duplex = adapter->hw.forced_speed_duplex;
 		uint8_t autoneg = adapter->hw.autoneg;
 
+		DPRINTK(HW, INFO, "offline testing starting\n");
+
 		/* Link test performed before hardware reset so autoneg doesn't
 		 * interfere with test result */
 		if (e1000_link_test(adapter, &data[4]))
@@ -1629,6 +1633,8 @@ e1000_diag_test(struct net_device *netde
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
 		e1000_reset(adapter);
+		/* make sure the phy is powered up */
+		e1000_power_up_phy(adapter);
 		if (e1000_loopback_test(adapter, &data[3]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
@@ -1642,6 +1648,7 @@ e1000_diag_test(struct net_device *netde
 		if (if_running)
 			dev_open(netdev);
 	} else {
+		DPRINTK(HW, INFO, "online testing starting\n");
 		/* Online tests */
 		if (e1000_link_test(adapter, &data[4]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index bd7770f..b2caaa2 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -484,7 +484,7 @@ e1000_up(struct e1000_adapter *adapter)
  *
  **/
 
-static void e1000_power_up_phy(struct e1000_adapter *adapter)
+void e1000_power_up_phy(struct e1000_adapter *adapter)
 {
 	uint16_t mii_reg = 0;
 



--
Auke Kok <auke-jan.h.kok@intel.com>
