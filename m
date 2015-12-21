From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] switchdev: bridge: Pass ageing time as clock_t instead of jiffies
Date: Mon, 21 Dec 2015 09:56:01 +0100
Message-ID: <1450688161-4792-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, stephen@networkplumber.org,
	Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:34508 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751191AbbLUI4E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2015 03:56:04 -0500
Received: by mail-wm0-f47.google.com with SMTP id l126so59016764wml.1
        for <netdev@vger.kernel.org>; Mon, 21 Dec 2015 00:56:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The bridge's ageing time is offloaded to hardware when:
	1) A port joins a bridge
	2) The ageing time of the bridge is changed

In the first case the ageing time is offloaded as jiffies, but in the
second case it's offloaded as clock_t, which is what existing switchdev
drivers expect to receive.

Fixes: 6ac311ae8bfb ("Adding switchdev ageing notification on port bridged")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/bridge/br_stp_if.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
index 5396ff08..12045de 100644
--- a/net/bridge/br_stp_if.c
+++ b/net/bridge/br_stp_if.c
@@ -39,7 +39,7 @@ void br_init_port(struct net_bridge_port *p)
 	struct switchdev_attr attr = {
 		.id = SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME,
 		.flags = SWITCHDEV_F_SKIP_EOPNOTSUPP | SWITCHDEV_F_DEFER,
-		.u.ageing_time = p->br->ageing_time,
+		.u.ageing_time = jiffies_to_clock_t(p->br->ageing_time),
 	};
 	int err;
 
-- 
2.4.3
