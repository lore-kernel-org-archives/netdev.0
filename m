From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 9/9] ixgbe: Cleanup PCIe bus speed info
Date: Wed,  4 May 2011 12:30:41 -0700
Message-ID: <1304537441-2056-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1304537441-2056-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:65312 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754312Ab1EDTau (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2011 15:30:50 -0400
In-Reply-To: <1304537441-2056-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

PCIe connections should be expressed as GT/s (GigaTransfers per second)
instead of the current Gb/s (Gigabits per second).  In addition, it is
incorrect because (due to PCIe gen 1 & 2 having a 20% overhead) the
actually data rate, when expressed in Gb/s, is only 80% of the rate of
GT/s.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Evan Swanson <evan.swanson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index bd3d21d..eebb192 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -7469,8 +7469,8 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 
 	/* print bus type/speed/width info */
 	e_dev_info("(PCI Express:%s:%s) %pM\n",
-		   (hw->bus.speed == ixgbe_bus_speed_5000 ? "5.0Gb/s" :
-		    hw->bus.speed == ixgbe_bus_speed_2500 ? "2.5Gb/s" :
+		   (hw->bus.speed == ixgbe_bus_speed_5000 ? "5.0GT/s" :
+		    hw->bus.speed == ixgbe_bus_speed_2500 ? "2.5GT/s" :
 		    "Unknown"),
 		   (hw->bus.width == ixgbe_bus_width_pcie_x8 ? "Width x8" :
 		    hw->bus.width == ixgbe_bus_width_pcie_x4 ? "Width x4" :
-- 
1.7.4.4

