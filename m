From: Roland Dreier <roland@kernel.org>
Subject: [PATCH] net: Reorder initialization in ip_route_output to fix gcc warning
Date: Sun, 10 Jun 2012 23:05:24 -0700
Message-ID: <1339394724-28296-1-git-send-email-roland@kernel.org>
Cc: netdev@vger.kernel.org, Roland Dreier <roland@purestorage.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog107.obsmtp.com ([74.125.245.82]:57289 "HELO
	na3sys010aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751144Ab2FKGF3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 02:05:29 -0400
Received: by pbbrp12 with SMTP id rp12so5468517pbb.29
        for <netdev@vger.kernel.org>; Sun, 10 Jun 2012 23:05:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Dreier <roland@purestorage.com>

If I build with W=1, for every file that includes <net/route.h>, I get the warning

    include/net/route.h: In function 'ip_route_output':
    include/net/route.h:135:3: warning: initialized field overwritten [-Woverride-init]
    include/net/route.h:135:3: warning: (near initialization for 'fl4') [-Woverride-init]

(This is with "gcc (Debian 4.6.3-1) 4.6.3")

A fix seems pretty trivial: move the initialization of .flowi4_tos
earlier.  As far as I can tell, this has no effect on code generation.

Signed-off-by: Roland Dreier <roland@purestorage.com>
---
 include/net/route.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/route.h b/include/net/route.h
index ed2b78e..9870546 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -130,9 +130,9 @@ static inline struct rtable *ip_route_output(struct net *net, __be32 daddr,
 {
 	struct flowi4 fl4 = {
 		.flowi4_oif = oif,
+		.flowi4_tos = tos,
 		.daddr = daddr,
 		.saddr = saddr,
-		.flowi4_tos = tos,
 	};
 	return ip_route_output_key(net, &fl4);
 }
-- 
1.7.9.5
