From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 3/5] e1000: cleanup link up/down messages
Date: Wed, 26 Nov 2008 16:02:35 -0800
Message-ID: <20081127000235.22431.40175.stgit@gitlost.lost>
References: <20081127000206.22431.53339.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.emeryville.ca.mail.comcast.net ([76.96.30.48]:39293 "EHLO
	QMTA05.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752498AbYK0ACs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 19:02:48 -0500
In-Reply-To: <20081127000206.22431.53339.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The system log messages created on a link status change need to follow a
specific format to work with tools some customers use.  This also makes
the messages consistant with other Intel driver link messages.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_main.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 5c098c9..6494d24 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2524,10 +2524,11 @@ static void e1000_watchdog(unsigned long data)
 			                           &adapter->link_duplex);
 
 			ctrl = er32(CTRL);
-			DPRINTK(LINK, INFO, "NIC Link is Up %d Mbps %s, "
-			        "Flow Control: %s\n",
-			        adapter->link_speed,
-			        adapter->link_duplex == FULL_DUPLEX ?
+			printk(KERN_INFO "e1000: %s NIC Link is Up %d Mbps %s, "
+			       "Flow Control: %s\n",
+			       netdev->name,
+			       adapter->link_speed,
+			       adapter->link_duplex == FULL_DUPLEX ?
 			        "Full Duplex" : "Half Duplex",
 			        ((ctrl & E1000_CTRL_TFCE) && (ctrl &
 			        E1000_CTRL_RFCE)) ? "RX/TX" : ((ctrl &
@@ -2603,7 +2604,8 @@ static void e1000_watchdog(unsigned long data)
 		if (netif_carrier_ok(netdev)) {
 			adapter->link_speed = 0;
 			adapter->link_duplex = 0;
-			DPRINTK(LINK, INFO, "NIC Link is Down\n");
+			printk(KERN_INFO "e1000: %s NIC Link is Down\n",
+			       netdev->name);
 			netif_carrier_off(netdev);
 			netif_stop_queue(netdev);
 			mod_timer(&adapter->phy_info_timer, round_jiffies(jiffies + 2 * HZ));

