From: Florian Fainelli <ffainelli@freebox.fr>
Subject: [PATCH 1/2] e1000: unmap ce4100_gbe_mdio_base_virt in e1000_remove
Date: Wed,  7 Dec 2011 17:41:01 +0100
Message-ID: <1323276062-10906-1-git-send-email-ffainelli@freebox.fr>
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Florian Fainelli <ffainelli@freebox.fr>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:33740 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752294Ab1LGQvb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Dec 2011 11:51:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are not unmapping ce4100_gbe_mdio_base_virt in exit path in case
we are running on a CE4100 adapter, fix that.

Signed-off-by: Florian Fainelli <ffainelli@freebox.fr>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 82f4ef1..7bb3337 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -1286,6 +1286,8 @@ static void __devexit e1000_remove(struct pci_dev *pdev)
 	kfree(adapter->tx_ring);
 	kfree(adapter->rx_ring);
 
+	if (hw->mac_type == e1000_ce4100)
+		iounmap(ce4100_gbe_mdio_base_virt);
 	iounmap(hw->hw_addr);
 	if (hw->flash_address)
 		iounmap(hw->flash_address);
-- 
1.7.5.4
