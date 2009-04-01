From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 1/5] igb: add support for x2 link width configurations
Date: Tue, 31 Mar 2009 23:38:00 -0700
Message-ID: <20090401063759.3046.89960.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.westchester.pa.mail.comcast.net ([76.96.62.96]:49655
	"EHLO QMTA09.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754104AbZDAGiU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 02:38:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

When device is on PCIe link trained as x2 the driver is currently reporting
link width as "unknown".  The original patch provided by Myron adds the x2
link support and my changes are cosmetic to clean up the readability of the
conditional operators.

Based on work by: Myron Stowe <myron.stowe@hp.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index ca84216..be02045 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1476,9 +1476,10 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 		 netdev->name,
 		 ((hw->bus.speed == e1000_bus_speed_2500)
 		  ? "2.5Gb/s" : "unknown"),
-		 ((hw->bus.width == e1000_bus_width_pcie_x4)
-		  ? "Width x4" : (hw->bus.width == e1000_bus_width_pcie_x1)
-		  ? "Width x1" : "unknown"),
+		 ((hw->bus.width == e1000_bus_width_pcie_x4) ? "Width x4" :
+		  (hw->bus.width == e1000_bus_width_pcie_x2) ? "Width x2" :
+		  (hw->bus.width == e1000_bus_width_pcie_x1) ? "Width x1" :
+		   "unknown"),
 		 netdev->dev_addr);
 
 	igb_read_part_num(hw, &part_num);

