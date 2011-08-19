From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] net: rps: support PPPOE session messages
Date: Fri, 19 Aug 2011 13:53:55 +0800
Message-ID: <1313733235-32238-1-git-send-email-xiaosuo@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:41120 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751293Ab1HSFys (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 01:54:48 -0400
Received: by pzk37 with SMTP id 37so4276408pzk.1
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2011 22:54:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Inspect the payload of PPPOE session messages for the 4 tuples to generate
skb->rxhash.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/core/dev.c |    8 ++++++++
 1 file changed, 8 insertions(+)
diff --git a/net/core/dev.c b/net/core/dev.c
index be7ee50..c2442b4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -134,6 +134,7 @@
 #include <linux/inetdevice.h>
 #include <linux/cpu_rmap.h>
 #include <linux/if_tunnel.h>
+#include <linux/if_pppox.h>
 
 #include "net-sysfs.h"
 
@@ -2573,6 +2574,13 @@ again:
 		proto = vlan->h_vlan_encapsulated_proto;
 		nhoff += sizeof(*vlan);
 		goto again;
+	case __constant_htons(ETH_P_PPP_SES):
+		if (!pskb_may_pull(skb, PPPOE_SES_HLEN + nhoff))
+			goto done;
+		proto = *((__be16 *) (skb->data + nhoff +
+				      sizeof(struct pppoe_hdr)));
+		nhoff += PPPOE_SES_HLEN;
+		goto again;
 	default:
 		goto done;
 	}
