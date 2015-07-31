From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net-next 3/4] bridge: Don't segment multiple tagged packets on bridge device
Date: Fri, 31 Jul 2015 15:03:26 +0900
Message-ID: <1438322608-4688-4-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1438322608-4688-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: "David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:34462 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751678AbbGaGD6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 02:03:58 -0400
In-Reply-To: <1438322608-4688-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bridge devices don't need to segment multiple tagged packets since thier
ports can segment them.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 net/bridge/br_device.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 4ff77a1..0aa8f5c 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -339,6 +339,7 @@ static const struct net_device_ops br_netdev_ops = {
 	.ndo_bridge_getlink	 = br_getlink,
 	.ndo_bridge_setlink	 = br_setlink,
 	.ndo_bridge_dellink	 = br_dellink,
+	.ndo_features_check	 = passthru_features_check,
 };
 
 static void br_dev_free(struct net_device *dev)
-- 
1.8.1.2
