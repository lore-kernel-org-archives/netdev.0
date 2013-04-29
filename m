From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next 1/3] bridge: use the bridge IP addr as source addr of querier
Date: Mon, 29 Apr 2013 15:26:30 +0800
Message-ID: <1367220392-17496-1-git-send-email-amwang@redhat.com>
Cc: Herbert Xu <herbert@gondor.hengli.com.au>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Adam Baker <linux@baker-net.org.uk>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28105 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751262Ab3D2H1K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Apr 2013 03:27:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

Quote from Adam:
"If it is believed that the use of 0.0.0.0
as the IP address is what is causing strange behaviour on other devices
then is there a good reason that a bridge rather than a router shouldn't
be the active querier? If not then using the bridge IP address and
having the querier enabled by default may be a reasonable solution
(provided that our querier obeys the election rules and shuts up if it
sees a query from a lower IP address that isn't 0.0.0.0). Just because a
device is the elected querier for IGMP doesn't appear to mean it is
required to perform any other routing functions."

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Adam Baker <linux@baker-net.org.uk>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/bridge/br_multicast.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 81f2389..6cb937c 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -23,6 +23,7 @@
 #include <linux/skbuff.h>
 #include <linux/slab.h>
 #include <linux/timer.h>
+#include <linux/inetdevice.h>
 #include <net/ip.h>
 #if IS_ENABLED(CONFIG_IPV6)
 #include <net/ipv6.h>
@@ -381,7 +382,7 @@ static struct sk_buff *br_ip4_multicast_alloc_query(struct net_bridge *br,
 	iph->frag_off = htons(IP_DF);
 	iph->ttl = 1;
 	iph->protocol = IPPROTO_IGMP;
-	iph->saddr = 0;
+	iph->saddr = inet_select_addr(br->dev, 0, RT_SCOPE_LINK);
 	iph->daddr = htonl(INADDR_ALLHOSTS_GROUP);
 	((u8 *)&iph[1])[0] = IPOPT_RA;
 	((u8 *)&iph[1])[1] = 4;
-- 
1.7.7.6
