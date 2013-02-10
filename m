From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] bridge: use dev->addr_assign_type to see if user change mac
Date: Sun, 10 Feb 2013 22:41:01 +0100
Message-ID: <1360532461-21003-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:64155 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755786Ab3BJVlI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 16:41:08 -0500
Received: by mail-ee0-f48.google.com with SMTP id t10so2753690eei.7
        for <netdev@vger.kernel.org>; Sun, 10 Feb 2013 13:41:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

And remove no longer used br->flags.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/bridge/br_device.c  | 1 -
 net/bridge/br_private.h | 3 ---
 net/bridge/br_stp_if.c  | 2 +-
 3 files changed, 1 insertion(+), 5 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index e1bc090..ba6fb2d 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -176,7 +176,6 @@ static int br_set_mac_address(struct net_device *dev, void *p)
 		br_fdb_change_mac_address(br, addr->sa_data);
 		br_stp_change_bridge_id(br, addr->sa_data);
 	}
-	br->flags |= BR_SET_MAC_ADDR;
 	spin_unlock_bh(&br->lock);
 
 	return 0;
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 711094a..06e85d9 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -197,9 +197,6 @@ struct net_bridge
 	bool				nf_call_ip6tables;
 	bool				nf_call_arptables;
 #endif
-	unsigned long			flags;
-#define BR_SET_MAC_ADDR		0x00000001
-
 	u16				group_fwd_mask;
 
 	/* STP */
diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
index 7b5197c..0bdb4eb 100644
--- a/net/bridge/br_stp_if.c
+++ b/net/bridge/br_stp_if.c
@@ -216,7 +216,7 @@ bool br_stp_recalculate_bridge_id(struct net_bridge *br)
 	struct net_bridge_port *p;
 
 	/* user has chosen a value so keep it */
-	if (br->flags & BR_SET_MAC_ADDR)
+	if (br->dev->addr_assign_type == NET_ADDR_SET)
 		return false;
 
 	list_for_each_entry(p, &br->port_list, list) {
-- 
1.8.1.2
