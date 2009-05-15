From: Sascha Hlusiak <contact@saschahlusiak.de>
Subject: [PATCH 1/5] sit: Fail to create tunnel, if it already exists
Date: Fri, 15 May 2009 16:12:36 +0200
Message-ID: <1242396760-30568-1-git-send-email-contact@saschahlusiak.de>
Cc: Sascha Hlusiak <contact@saschahlusiak.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.177]:58460 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751602AbZEOOLq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2009 10:11:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When locating the tunnel, do not continue if it is found. Otherwise
a different tunnel with similar configuration would be returned and
parts could be overwritten.

Signed-off-by: Sascha Hlusiak <contact@saschahlusiak.de>
---
 net/ipv6/sit.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 664ab82..e625041 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -165,8 +165,13 @@ static struct ip_tunnel * ipip6_tunnel_locate(struct net *net,
 	struct sit_net *sitn = net_generic(net, sit_net_id);
 
 	for (tp = __ipip6_bucket(sitn, parms); (t = *tp) != NULL; tp = &t->next) {
-		if (local == t->parms.iph.saddr && remote == t->parms.iph.daddr)
-			return t;
+		if (local == t->parms.iph.saddr &&
+		    remote == t->parms.iph.daddr) {
+			if (create)
+				return NULL;
+			else
+				return t;
+		}
 	}
 	if (!create)
 		goto failed;
-- 
1.6.3

