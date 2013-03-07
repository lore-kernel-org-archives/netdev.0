From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next] bridge: use ipv4_is_local_multicast() helper
Date: Thu,  7 Mar 2013 20:32:26 +0800
Message-ID: <1362659546-22455-1-git-send-email-amwang@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13660 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751029Ab3CGMck (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Mar 2013 07:32:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 10e6fce..81d51b8 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1368,7 +1368,7 @@ static int br_multicast_ipv4_rcv(struct net_bridge *br,
 		return -EINVAL;
 
 	if (iph->protocol != IPPROTO_IGMP) {
-		if ((iph->daddr & IGMP_LOCAL_GROUP_MASK) != IGMP_LOCAL_GROUP)
+		if (!ipv4_is_local_multicast(iph->daddr))
 			BR_INPUT_SKB_CB(skb)->mrouters_only = 1;
 		return 0;
 	}
