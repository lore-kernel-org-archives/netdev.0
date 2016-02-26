From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next 2/3] bridge: mcast: do nothing if port's multicast_router is set to the same val
Date: Fri, 26 Feb 2016 19:59:25 +0100
Message-ID: <1456513166-20159-3-git-send-email-nikolay@cumulusnetworks.com>
References: <1456513166-20159-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: davem@davemloft.net, roopa@cumulusnetworks.com,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:37846 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754096AbcBZS7i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 13:59:38 -0500
Received: by mail-wm0-f43.google.com with SMTP id g62so82327225wme.0
        for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 10:59:37 -0800 (PST)
In-Reply-To: <1456513166-20159-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is needed for the upcoming temporary port router. There's no point
to go through the logic if the value is the same.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_multicast.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 015c47dd1364..496f808f9aa1 100644
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
 		__del_port_router(p);
-- 
2.4.3
