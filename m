From: Stefan Assmann <sassmann@redhat.com>
Subject: [net-next-2.6 PATCH] igbvf, ixgbevf: use dev_hw_addr_random
Date: Tue, 27 Jul 2010 11:24:50 +0200
Message-ID: <4C4EA5E2.1050909@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, jeffrey.t.kirsher@intel.com,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	David Miller <davem@davemloft.net>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59825 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755843Ab0G0JZF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jul 2010 05:25:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Assmann <sassmann@redhat.com>

Both igbvf and ixgbevf should set addr_assign_type to NET_ADDR_RANDOM
so udev creates persistent net rules by matching the device path.
Do this by using the dev_hw_addr_random helper function.

Signed-off-by: Stefan Assmann <sassmann@redhat.com>
---
 drivers/net/igbvf/netdev.c         |    2 +-
 drivers/net/ixgbevf/ixgbevf_main.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index 5e2b2a8..048595b 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -2751,7 +2751,7 @@ static int __devinit igbvf_probe(struct pci_dev *pdev,
 		dev_info(&pdev->dev,
 			 "PF still in reset state, assigning new address."
 			 " Is the PF interface up?\n");
-		random_ether_addr(hw->mac.addr);
+		dev_hw_addr_random(adapter->netdev, hw->mac.addr);
 	} else {
 		err = hw->mac.ops.read_mac_addr(hw);
 		if (err) {
diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index af49135..4867440 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -2229,7 +2229,7 @@ static int __devinit ixgbevf_sw_init(struct ixgbevf_adapter *adapter)
 	if (err) {
 		dev_info(&pdev->dev,
 		         "PF still in reset state, assigning new address\n");
-		random_ether_addr(hw->mac.addr);
+		dev_hw_addr_random(adapter->netdev, hw->mac.addr);
 	} else {
 		err = hw->mac.ops.init_hw(hw);
 		if (err) {
-- 
1.6.5.2

