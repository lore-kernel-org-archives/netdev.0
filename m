From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [UPDATED PATCH 6/7] igb: remove igb_init_managability as it is
	deprecated
Date: Mon, 04 Aug 2008 15:00:27 -0700
Message-ID: <20080804220023.16188.437.stgit@localhost.localdomain>
References: <20080804215531.16188.73257.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:13154 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750903AbYHDWA3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Aug 2008 18:00:29 -0400
In-Reply-To: <20080804215531.16188.73257.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

igb_init_managability does not actually perform any function as the two
registers it attempts to write are both read only on the host.  This patch
removes the function and all references to it from the driver.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   25 -------------------------
 1 files changed, 0 insertions(+), 25 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index cfed2b0..8f66e15 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -720,28 +720,6 @@ static void igb_get_hw_control(struct igb_adapter *adapter)
 			ctrl_ext | E1000_CTRL_EXT_DRV_LOAD);
 }
 
-static void igb_init_manageability(struct igb_adapter *adapter)
-{
-	struct e1000_hw *hw = &adapter->hw;
-
-	if (adapter->en_mng_pt) {
-		u32 manc2h = rd32(E1000_MANC2H);
-		u32 manc = rd32(E1000_MANC);
-
-		/* enable receiving management packets to the host */
-		/* this will probably generate destination unreachable messages
-		 * from the host OS, but the packets will be handled on SMBUS */
-		manc |= E1000_MANC_EN_MNG2HOST;
-#define E1000_MNG2HOST_PORT_623 (1 << 5)
-#define E1000_MNG2HOST_PORT_664 (1 << 6)
-		manc2h |= E1000_MNG2HOST_PORT_623;
-		manc2h |= E1000_MNG2HOST_PORT_664;
-		wr32(E1000_MANC2H, manc2h);
-
-		wr32(E1000_MANC, manc);
-	}
-}
-
 /**
  * igb_configure - configure the hardware for RX and TX
  * @adapter: private board structure
@@ -755,7 +733,6 @@ static void igb_configure(struct igb_adapter *adapter)
 	igb_set_multi(netdev);
 
 	igb_restore_vlan(adapter);
-	igb_init_manageability(adapter);
 
 	igb_configure_tx(adapter);
 	igb_setup_rctl(adapter);
@@ -4524,8 +4501,6 @@ static void igb_io_resume(struct pci_dev *pdev)
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct igb_adapter *adapter = netdev_priv(netdev);
 
-	igb_init_manageability(adapter);
-
 	if (netif_running(netdev)) {
 		if (igb_up(adapter)) {
 			dev_err(&pdev->dev, "igb_up failed after reset\n");

