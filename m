From: Joe Perches <joe@perches.com>
Subject: [PATCH] ixgbevf: Message formatting fixup
Date: Mon, 22 Mar 2010 12:12:37 -0700
Message-ID: <1269285157.22616.55.camel@Joe-Laptop.home>
References: <201003221759.o2MHxFlh015632@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Greg Rose <gregory.v.rose@intel.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1037 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755022Ab0CVTMj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Mar 2010 15:12:39 -0400
In-Reply-To: <201003221759.o2MHxFlh015632@hera.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 29b8dd024bd48c3d1d1e5140f5bbb683786f998e
left a trailing ", " after a message.
Fix it and make the text used a bit smaller when DEBUG is #defined

Signed-off-by: Joe Perches <joe@perches.com>
---
diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index d6cbd94..19e93a4 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -2417,9 +2417,9 @@ static void ixgbevf_watchdog_task(struct work_struct *work)
 
 	if (link_up) {
 		if (!netif_carrier_ok(netdev)) {
-			hw_dbg(&adapter->hw, "NIC Link is Up %s, ",
-			       ((link_speed == IXGBE_LINK_SPEED_10GB_FULL) ?
-				"10 Gbps\n" : "1 Gbps\n"));
+			hw_dbg(&adapter->hw, "NIC Link is Up, %u Gbps\n",
+			       (link_speed == IXGBE_LINK_SPEED_10GB_FULL) ?
+			       10 : 1);
 			netif_carrier_on(netdev);
 			netif_tx_wake_all_queues(netdev);
 		} else {



