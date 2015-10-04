From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 09/20] bridge: netlink: add fdb flush
Date: Sun,  4 Oct 2015 14:23:36 +0200
Message-ID: <1443961427-15085-10-git-send-email-razor@blackwall.org>
References: <1443961427-15085-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	shm@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:33090 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751530AbbJDMYS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Oct 2015 08:24:18 -0400
Received: by wiclk2 with SMTP id lk2so85746897wic.0
        for <netdev@vger.kernel.org>; Sun, 04 Oct 2015 05:24:17 -0700 (PDT)
In-Reply-To: <1443961427-15085-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Simple attribute that flushes the bridge's fdb.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/uapi/linux/if_link.h | 1 +
 net/bridge/br_netlink.c      | 3 +++
 2 files changed, 4 insertions(+)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index eaeaac17dfdd..9ca9bf8bfe04 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -244,6 +244,7 @@ enum {
 	IFLA_BR_TOPOLOGY_CHANGE_TIMER,
 	IFLA_BR_GC_TIMER,
 	IFLA_BR_GROUP_ADDR,
+	IFLA_BR_FDB_FLUSH,
 	__IFLA_BR_MAX,
 };
 
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index a05a4306d42d..5853c5737006 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -859,6 +859,9 @@ static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
 		br_recalculate_fwd_mask(br);
 	}
 
+	if (data[IFLA_BR_FDB_FLUSH])
+		br_fdb_flush(br);
+
 	return 0;
 }
 
-- 
2.4.3
