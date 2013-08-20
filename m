From: "Florian Fainelli" <f.fainelli@gmail.com>
Subject: [RFC PATCH] bridge: inherit slave devices needed_headroom
Date: Tue, 20 Aug 2013 10:21:45 +0100
Message-ID: <1376990505-15708-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, eric.dumazet@gmail.com,
	vyasevic@redhat.com, davem@davemloft.net,
	"Florian Fainelli" <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3678 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750795Ab3HTJWV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Aug 2013 05:22:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some slave devices may have set a dev->needed_headroom value which is
different than the default one, most likely in order to prepend a
hardware descriptor in front of the Ethernet frame to send. Whenever a
new slave is added to a bridge, ensure that we update the
needed_headroom value accordingly to account for the slave
needed_headroom value.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/bridge/br_if.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index aa6c9a8..c41d5fb 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -383,6 +383,9 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 
 	netdev_update_features(br->dev);
 
+	if (br->dev->needed_headroom < dev->needed_headroom)
+		br->dev->needed_headroom = dev->needed_headroom;
+
 	spin_lock_bh(&br->lock);
 	changed_addr = br_stp_recalculate_bridge_id(br);
 
-- 
1.8.1.2
