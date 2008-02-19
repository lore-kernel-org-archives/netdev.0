From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH] [2.6.25-rc2] igb: Fix panic with NICs with 1000BASE-SX PHY
Date: Tue, 19 Feb 2008 12:46:03 -0500
Message-ID: <20080219174603.GN856@gospo.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: auke-jan.h.kok@intel.com, jeff@garzik.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:45735 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753840AbYBSRqU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Feb 2008 12:46:20 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bill Hayes <bill.hayes@hp.com>

Auke, Jeff and David,

This patch eliminates a kernel panic with the igb driver in 2.6.25-rc2 when 
running on a Intel 82575 Ethernet controller with a 1000BASE-SX PHY.  The 
panic does not happen with the 1000BASE-T PHY, only with a SX connection.  

Signed-off-by: Bill Hayes <bill.hayes@hp.com>
Signed-off-by: Andy Gospodarek <andy@greyhouse.net>

 drivers/net/igb/igb_main.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index d4eb8e2..666c8f0 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -843,7 +843,8 @@ void igb_reset(struct igb_adapter *adapter)
 	wr32(E1000_VET, ETHERNET_IEEE_VLAN_TYPE);
 
 	igb_reset_adaptive(&adapter->hw);
-	adapter->hw.phy.ops.get_phy_info(&adapter->hw);
+	if (adapter->hw.phy.ops.get_phy_info)
+		adapter->hw.phy.ops.get_phy_info(&adapter->hw);
 	igb_release_manageability(adapter);
 }
 
@@ -2083,7 +2084,8 @@ static void igb_set_multi(struct net_device *netdev)
 static void igb_update_phy_info(unsigned long data)
 {
 	struct igb_adapter *adapter = (struct igb_adapter *) data;
-	adapter->hw.phy.ops.get_phy_info(&adapter->hw);
+	if (adapter->hw.phy.ops.get_phy_info)
+		adapter->hw.phy.ops.get_phy_info(&adapter->hw);
 }
 
 /**



