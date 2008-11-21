From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 13/14] e1000e: fix incorrect link status when switch
	module pulled
Date: Fri, 21 Nov 2008 11:02:39 -0800
Message-ID: <20081121190239.32313.89514.stgit@gitlost.lost>
References: <20081121185859.32313.42332.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.emeryville.ca.mail.comcast.net ([76.96.30.16]:56772 "EHLO
	QMTA01.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754532AbYKUTC5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 14:02:57 -0500
In-Reply-To: <20081121185859.32313.42332.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

On 82571 with SerDes, the true link state is not always correct when read
from the STATUS register; use existing e1000_has_link() function instead.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/e1000.h   |    1 +
 drivers/net/e1000e/ethtool.c |    7 ++-----
 drivers/net/e1000e/netdev.c  |    2 +-
 3 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index ec94991..da6a799 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -387,6 +387,7 @@ extern int e1000e_setup_tx_resources(struct e1000_adapter *adapter);
 extern void e1000e_free_rx_resources(struct e1000_adapter *adapter);
 extern void e1000e_free_tx_resources(struct e1000_adapter *adapter);
 extern void e1000e_update_stats(struct e1000_adapter *adapter);
+extern bool e1000_has_link(struct e1000_adapter *adapter);
 extern void e1000e_set_interrupt_capability(struct e1000_adapter *adapter);
 extern void e1000e_reset_interrupt_capability(struct e1000_adapter *adapter);
 
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 840e8c4..34f1f63 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -173,11 +173,8 @@ static int e1000_get_settings(struct net_device *netdev,
 static u32 e1000_get_link(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	struct e1000_hw *hw = &adapter->hw;
-	u32 status;
-	
-	status = er32(STATUS);
-	return (status & E1000_STATUS_LU) ? 1 : 0;
+
+	return e1000_has_link(adapter);
 }
 
 static int e1000_set_spd_dplx(struct e1000_adapter *adapter, u16 spddplx)
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index b3f0b47..b1b534d 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -3421,7 +3421,7 @@ static void e1000_print_link_info(struct e1000_adapter *adapter)
 	       ((ctrl & E1000_CTRL_TFCE) ? "TX" : "None" )));
 }
 
-static bool e1000_has_link(struct e1000_adapter *adapter)
+bool e1000_has_link(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	bool link_active = 0;

