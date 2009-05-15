From: Sascha Hlusiak <contact@saschahlusiak.de>
Subject: [PATCH 1/5] sit: Fail to create tunnel, if it already exists,
Date: Fri, 15 May 2009 14:52:47 +0200
Message-ID: <1242391971-32583-1-git-send-email-contact@saschahlusiak.de>
Cc: Sascha Hlusiak <contact@saschahlusiak.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:55138 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753332AbZEOMwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2009 08:52:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When locating the tunnel, do not continue if it is found. Otherwise
a different tunnel with similar configuration would be returned and
parts could be overwritten.
---
 net/ipv6/sit.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 664ab82..bd63a7e 100644
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

