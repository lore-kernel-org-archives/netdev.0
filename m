From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 08/14] e1000e: link up/down messages must follow a
	specific format
Date: Fri, 21 Nov 2008 11:01:10 -0800
Message-ID: <20081121190110.32313.43591.stgit@gitlost.lost>
References: <20081121185859.32313.42332.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.emeryville.ca.mail.comcast.net ([76.96.30.96]:37833 "EHLO
	QMTA09.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752610AbYKUTB2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 14:01:28 -0500
In-Reply-To: <20081121185859.32313.42332.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The system log messages created on a link status change need to follow a
specific format to work with tools some customers use.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 7eb1a36..cd6d132 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -3408,7 +3408,10 @@ static void e1000_print_link_info(struct e1000_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	u32 ctrl = er32(CTRL);
 
-	e_info("Link is Up %d Mbps %s, Flow Control: %s\n",
+	/* Link status message must follow this format for user tools */
+	printk(KERN_INFO "e1000e: %s NIC Link is Up %d Mbps %s, "
+	       "Flow Control: %s\n",
+	       adapter->netdev->name,
 	       adapter->link_speed,
 	       (adapter->link_duplex == FULL_DUPLEX) ?
 	                        "Full Duplex" : "Half Duplex",
@@ -3618,7 +3621,9 @@ static void e1000_watchdog_task(struct work_struct *work)
 		if (netif_carrier_ok(netdev)) {
 			adapter->link_speed = 0;
 			adapter->link_duplex = 0;
-			e_info("Link is Down\n");
+			/* Link status message must follow this format */
+			printk(KERN_INFO "e1000e: %s NIC Link is Down\n",
+			       adapter->netdev->name);
 			netif_carrier_off(netdev);
 			netif_tx_stop_all_queues(netdev);
 			if (!test_bit(__E1000_DOWN, &adapter->state))

