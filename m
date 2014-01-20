From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/7] appletalk: Use ether_addr_copy
Date: Mon, 20 Jan 2014 09:52:15 -0800
Message-ID: <a69cec0feb40321e14ced127c139e149e731ed55.1390239869.git.joe@perches.com>
References: <cover.1390239869.git.joe@perches.com>
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0108.hostedemail.com ([216.40.44.108]:36111 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753358AbaATRwc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jan 2014 12:52:32 -0500
In-Reply-To: <cover.1390239869.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use ether_addr_copy instead of memcpy(a, b, ETH_ALEN) to
save some cycles on arm and powerpc.

Convert struct aarp_entry.hwaddr[6] to hwaddr[ETH_ALEN].

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/appletalk/aarp.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/appletalk/aarp.c b/net/appletalk/aarp.c
index 690356f..d0b7be1 100644
--- a/net/appletalk/aarp.c
+++ b/net/appletalk/aarp.c
@@ -67,7 +67,7 @@ struct aarp_entry {
 	unsigned long		expires_at;
 	struct atalk_addr	target_addr;
 	struct net_device	*dev;
-	char			hwaddr[6];
+	char			hwaddr[ETH_ALEN];
 	unsigned short		xmit_count;
 	struct aarp_entry	*next;
 };
@@ -134,7 +134,7 @@ static void __aarp_send_query(struct aarp_entry *a)
 	eah->pa_len	 = AARP_PA_ALEN;
 	eah->function	 = htons(AARP_REQUEST);
 
-	memcpy(eah->hw_src, dev->dev_addr, ETH_ALEN);
+	ether_addr_copy(eah->hw_src, dev->dev_addr);
 
 	eah->pa_src_zero = 0;
 	eah->pa_src_net	 = sat->s_net;
@@ -181,7 +181,7 @@ static void aarp_send_reply(struct net_device *dev, struct atalk_addr *us,
 	eah->pa_len	 = AARP_PA_ALEN;
 	eah->function	 = htons(AARP_REPLY);
 
-	memcpy(eah->hw_src, dev->dev_addr, ETH_ALEN);
+	ether_addr_copy(eah->hw_src, dev->dev_addr);
 
 	eah->pa_src_zero = 0;
 	eah->pa_src_net	 = us->s_net;
@@ -190,7 +190,7 @@ static void aarp_send_reply(struct net_device *dev, struct atalk_addr *us,
 	if (!sha)
 		memset(eah->hw_dst, '\0', ETH_ALEN);
 	else
-		memcpy(eah->hw_dst, sha, ETH_ALEN);
+		ether_addr_copy(eah->hw_dst, sha);
 
 	eah->pa_dst_zero = 0;
 	eah->pa_dst_net	 = them->s_net;
@@ -232,7 +232,7 @@ static void aarp_send_probe(struct net_device *dev, struct atalk_addr *us)
 	eah->pa_len	 = AARP_PA_ALEN;
 	eah->function	 = htons(AARP_PROBE);
 
-	memcpy(eah->hw_src, dev->dev_addr, ETH_ALEN);
+	ether_addr_copy(eah->hw_src, dev->dev_addr);
 
 	eah->pa_src_zero = 0;
 	eah->pa_src_net	 = us->s_net;
@@ -790,7 +790,7 @@ static int aarp_rcv(struct sk_buff *skb, struct net_device *dev,
 			break;
 
 		/* We can fill one in - this is good. */
-		memcpy(a->hwaddr, ea->hw_src, ETH_ALEN);
+		ether_addr_copy(a->hwaddr, ea->hw_src);
 		__aarp_resolved(&unresolved[hash], a, hash);
 		if (!unresolved_count)
 			mod_timer(&aarp_timer,
-- 
1.8.1.2.459.gbcd45b4.dirty
