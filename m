From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] igb: Fix panic with NICs with 1000BASE-SX PHY
Date: Tue, 19 Feb 2008 10:24:41 -0800
Message-ID: <20080219182441.12033.64731.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	bill.hayes@hp.com, andy@greyhouse.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:25348 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753070AbYBSS0E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Feb 2008 13:26:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bill Hayes <bill.hayes@hp.com>

This patch eliminates a kernel panic with the igb driver in 2.6.25-rc2 when 
running on a Intel 82575 Ethernet controller with a 1000BASE-SX PHY.  The 
panic does not happen with the 1000BASE-T PHY, only with a SX connection.  

Signed-off-by: Bill Hayes <bill.hayes@hp.com>
Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/igb/igb_main.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 3480cc7..6a1f230 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -816,7 +816,8 @@ void igb_reset(struct igb_adapter *adapter)
 	wr32(E1000_VET, ETHERNET_IEEE_VLAN_TYPE);
 
 	igb_reset_adaptive(&adapter->hw);
-	adapter->hw.phy.ops.get_phy_info(&adapter->hw);
+	if (adapter->hw.phy.ops.get_phy_info)
+		adapter->hw.phy.ops.get_phy_info(&adapter->hw);
 }
 
 /**
@@ -2052,7 +2053,8 @@ static void igb_set_multi(struct net_device *netdev)
 static void igb_update_phy_info(unsigned long data)
 {
 	struct igb_adapter *adapter = (struct igb_adapter *) data;
-	adapter->hw.phy.ops.get_phy_info(&adapter->hw);
+	if (adapter->hw.phy.ops.get_phy_info)
+		adapter->hw.phy.ops.get_phy_info(&adapter->hw);
 }
 
 /**

