From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 2/5] ixgbe: cleanup link up/down messages
Date: Wed, 26 Nov 2008 16:02:22 -0800
Message-ID: <20081127000222.22431.45986.stgit@gitlost.lost>
References: <20081127000206.22431.53339.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.emeryville.ca.mail.comcast.net ([76.96.30.64]:43567 "EHLO
	QMTA07.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752498AbYK0ACr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 19:02:47 -0500
In-Reply-To: <20081127000206.22431.53339.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The system log messages created on a link status change need to follow a
specific format to work with tools some customers use.  This also makes
the messages consistant with other Intel driver link messages.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   22 ++++++++++++----------
 1 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 15d511c..fbe19ee 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3456,15 +3456,16 @@ static void ixgbe_watchdog_task(struct work_struct *work)
 			u32 rmcs = IXGBE_READ_REG(hw, IXGBE_RMCS);
 #define FLOW_RX (frctl & IXGBE_FCTRL_RFCE)
 #define FLOW_TX (rmcs & IXGBE_RMCS_TFCE_802_3X)
-			DPRINTK(LINK, INFO, "NIC Link is Up %s, "
-			        "Flow Control: %s\n",
-			        (link_speed == IXGBE_LINK_SPEED_10GB_FULL ?
-			         "10 Gbps" :
-			         (link_speed == IXGBE_LINK_SPEED_1GB_FULL ?
-			          "1 Gbps" : "unknown speed")),
-			        ((FLOW_RX && FLOW_TX) ? "RX/TX" :
-			         (FLOW_RX ? "RX" :
-			         (FLOW_TX ? "TX" : "None"))));
+			printk(KERN_INFO "ixgbe: %s NIC Link is Up %s, "
+			       "Flow Control: %s\n",
+			       netdev->name,
+			       (link_speed == IXGBE_LINK_SPEED_10GB_FULL ?
+			        "10 Gbps" :
+			        (link_speed == IXGBE_LINK_SPEED_1GB_FULL ?
+			         "1 Gbps" : "unknown speed")),
+			       ((FLOW_RX && FLOW_TX) ? "RX/TX" :
+			        (FLOW_RX ? "RX" :
+			        (FLOW_TX ? "TX" : "None"))));
 
 			netif_carrier_on(netdev);
 			netif_tx_wake_all_queues(netdev);
@@ -3476,7 +3477,8 @@ static void ixgbe_watchdog_task(struct work_struct *work)
 		adapter->link_up = false;
 		adapter->link_speed = 0;
 		if (netif_carrier_ok(netdev)) {
-			DPRINTK(LINK, INFO, "NIC Link is Down\n");
+			printk(KERN_INFO "ixgbe: %s NIC Link is Down\n",
+			       netdev->name);
 			netif_carrier_off(netdev);
 			netif_tx_stop_all_queues(netdev);
 		}

