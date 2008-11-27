From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 1/5] igb: link up/down messages must follow a
	specific format
Date: Wed, 26 Nov 2008 16:02:06 -0800
Message-ID: <20081127000206.22431.53339.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.emeryville.ca.mail.comcast.net ([76.96.30.24]:38882 "EHLO
	QMTA02.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751403AbYK0ACW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 19:02:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The system log messages created on a link status change need to follow a
specific format to work with tools some customers use.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index ab37ab0..0919a2f 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -2328,9 +2328,10 @@ static void igb_watchdog_task(struct work_struct *work)
 						   &adapter->link_duplex);
 
 			ctrl = rd32(E1000_CTRL);
-			dev_info(&adapter->pdev->dev,
-				 "NIC Link is Up %d Mbps %s, "
+			/* Links status message must follow this format */
+			printk(KERN_INFO "igb: %s NIC Link is Up %d Mbps %s, "
 				 "Flow Control: %s\n",
+			         netdev->name,
 				 adapter->link_speed,
 				 adapter->link_duplex == FULL_DUPLEX ?
 				 "Full Duplex" : "Half Duplex",
@@ -2365,7 +2366,9 @@ static void igb_watchdog_task(struct work_struct *work)
 		if (netif_carrier_ok(netdev)) {
 			adapter->link_speed = 0;
 			adapter->link_duplex = 0;
-			dev_info(&adapter->pdev->dev, "NIC Link is Down\n");
+			/* Links status message must follow this format */
+			printk(KERN_INFO "igb: %s NIC Link is Down\n",
+			       netdev->name);
 			netif_carrier_off(netdev);
 			netif_tx_stop_all_queues(netdev);
 			if (!test_bit(__IGB_DOWN, &adapter->state))

