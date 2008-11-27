From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 4/5] ixgb: cleanup link up/down messages
Date: Wed, 26 Nov 2008 16:02:48 -0800
Message-ID: <20081127000248.22431.86283.stgit@gitlost.lost>
References: <20081127000206.22431.53339.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.emeryville.ca.mail.comcast.net ([76.96.30.16]:45999 "EHLO
	QMTA01.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752557AbYK0ADD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 19:03:03 -0500
In-Reply-To: <20081127000206.22431.53339.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The system log messages created on a link status change need to follow a
specific format to work with tools some customers use.  This also makes
the messages consistant with other Intel driver link messages.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgb/ixgb_main.c |   14 +++++++++++---
 1 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index a04e389..820a92c 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1110,8 +1110,15 @@ ixgb_watchdog(unsigned long data)
 
 	if (adapter->hw.link_up) {
 		if (!netif_carrier_ok(netdev)) {
-			DPRINTK(LINK, INFO,
-			        "NIC Link is Up 10000 Mbps Full Duplex\n");
+			printk(KERN_INFO "ixgb: %s NIC Link is Up 10 Gbps "
+			       "Full Duplex, Flow Control: %s\n",
+			       netdev->name,
+			       (adapter->hw.fc.type == ixgb_fc_full) ?
+			        "RX/TX" :
+			        ((adapter->hw.fc.type == ixgb_fc_rx_pause) ?
+			         "RX" :
+			         ((adapter->hw.fc.type == ixgb_fc_tx_pause) ?
+			          "TX" : "None")));
 			adapter->link_speed = 10000;
 			adapter->link_duplex = FULL_DUPLEX;
 			netif_carrier_on(netdev);
@@ -1121,7 +1128,8 @@ ixgb_watchdog(unsigned long data)
 		if (netif_carrier_ok(netdev)) {
 			adapter->link_speed = 0;
 			adapter->link_duplex = 0;
-			DPRINTK(LINK, INFO, "NIC Link is Down\n");
+			printk(KERN_INFO "ixgb: %s NIC Link is Down\n",
+			       netdev->name);
 			netif_carrier_off(netdev);
 			netif_stop_queue(netdev);
 

