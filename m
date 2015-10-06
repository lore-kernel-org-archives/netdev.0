From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 7/8] bridge: netlink: allow to flush port's fdb
Date: Tue,  6 Oct 2015 14:12:01 +0200
Message-ID: <1444133522-16907-8-git-send-email-razor@blackwall.org>
References: <1444133522-16907-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	shm@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:37492 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752282AbbJFMMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 08:12:32 -0400
Received: by wicfx3 with SMTP id fx3so155693044wic.0
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2015 05:12:31 -0700 (PDT)
In-Reply-To: <1444133522-16907-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Add IFLA_BRPORT_FLUSH to allow flushing port's fdb similar to sysfs's
flush.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/uapi/linux/if_link.h | 1 +
 net/bridge/br_netlink.c      | 3 +++
 2 files changed, 4 insertions(+)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 9c17f605e013..fcea39a56095 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -303,6 +303,7 @@ enum {
 	IFLA_BRPORT_MESSAGE_AGE_TIMER,
 	IFLA_BRPORT_FORWARD_DELAY_TIMER,
 	IFLA_BRPORT_HOLD_TIMER,
+	IFLA_BRPORT_FLUSH,
 	__IFLA_BRPORT_MAX
 };
 #define IFLA_BRPORT_MAX (__IFLA_BRPORT_MAX - 1)
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 04b0e5072686..6468166d6bdc 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -631,6 +631,9 @@ static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
 			return err;
 	}
 
+	if (tb[IFLA_BRPORT_FLUSH])
+		br_fdb_delete_by_port(p->br, p, 0, 0);
+
 	br_port_flags_change(p, old_flags ^ p->flags);
 	return 0;
 }
-- 
2.4.3
