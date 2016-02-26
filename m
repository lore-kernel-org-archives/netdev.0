From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next v2 2/4] bridge: mcast: do nothing if port's multicast_router is set to the same val
Date: Fri, 26 Feb 2016 21:20:02 +0100
Message-ID: <1456518004-25578-3-git-send-email-nikolay@cumulusnetworks.com>
References: <1456518004-25578-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: davem@davemloft.net, roopa@cumulusnetworks.com,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:35228 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755160AbcBZUUQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 15:20:16 -0500
Received: by mail-wm0-f45.google.com with SMTP id a4so1669396wme.0
        for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 12:20:15 -0800 (PST)
In-Reply-To: <1456518004-25578-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is needed for the upcoming temporary port router. There's no point
to go through the logic if the value is the same.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
v2: no change

 net/bridge/br_multicast.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 71c109b0943f..f1140cf5168d 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1853,7 +1853,10 @@ int br_multicast_set_port_router(struct net_bridge_port *p, unsigned long val)
 	int err = -EINVAL;
 
 	spin_lock(&br->multicast_lock);
-
+	if (p->multicast_router == val) {
+		err = 0;
+		goto unlock;
+	}
 	switch (val) {
 	case MDB_RTR_TYPE_DISABLED:
 		p->multicast_router = MDB_RTR_TYPE_DISABLED;
-- 
2.4.3
