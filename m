From: Zhu Yanjun <Yanjun.Zhu@windriver.com>
Subject: [PATCH 1/1] bridge: turn off carrier when the bridge is created
Date: Tue, 10 Mar 2015 15:09:42 +0800
Message-ID: <1425971382-14177-2-git-send-email-Yanjun.Zhu@windriver.com>
References: <1425971382-14177-1-git-send-email-Yanjun.Zhu@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:49297 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750920AbbCJHJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 03:09:24 -0400
In-Reply-To: <1425971382-14177-1-git-send-email-Yanjun.Zhu@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a bridge interface is created, there is no any sub interface
in it. In this case, the packets should not go to this bridge interface.
As such, carrier is turned off.

CC: David Ahern <dsahern@gmail.com>
Suggested-by: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>
---
 net/bridge/br_device.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index ffd379d..fcc4794 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -394,4 +394,8 @@ void br_dev_setup(struct net_device *dev)
 	br_netfilter_rtable_init(br);
 	br_stp_timer_init(br);
 	br_multicast_init(br);
+
+	/* Shutdown bridge to avoid packets */
+	if (netif_carrier_ok(dev))
+		netif_carrier_off(dev);
 }
-- 
1.9.1
