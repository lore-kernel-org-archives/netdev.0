From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next v2 1/4] vxlan: use reset to set header pointers
Date: Thu,  3 Mar 2016 01:16:54 +0000
Message-ID: <1456967817-7632-2-git-send-email-zhangshengju@cmss.chinamobile.com>
References: <1456967817-7632-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: davem@davemloft.net, kvalo@codeaurora.org,
	johannes@sipsolutions.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:8831 "EHLO
	cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750917AbcCCBPv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 20:15:51 -0500
In-Reply-To: <1456967817-7632-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since offset is zero, it's not necessary to use set function. Reset
function is straightforward, and will remove the unnecessary add operation
in set function.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 drivers/net/vxlan.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 775ddb4..8ca243d 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1460,7 +1460,7 @@ static struct sk_buff *vxlan_na_create(struct sk_buff *request,
 	reply->dev = dev;
 	skb_reserve(reply, LL_RESERVED_SPACE(request->dev));
 	skb_push(reply, sizeof(struct ethhdr));
-	skb_set_mac_header(reply, 0);
+	skb_reset_mac_header(reply);
 
 	ns = (struct nd_msg *)skb_transport_header(request);
 
@@ -1480,7 +1480,7 @@ static struct sk_buff *vxlan_na_create(struct sk_buff *request,
 	reply->protocol = htons(ETH_P_IPV6);
 
 	skb_pull(reply, sizeof(struct ethhdr));
-	skb_set_network_header(reply, 0);
+	skb_reset_network_header(reply);
 	skb_put(reply, sizeof(struct ipv6hdr));
 
 	/* IPv6 header */
@@ -1495,7 +1495,7 @@ static struct sk_buff *vxlan_na_create(struct sk_buff *request,
 	pip6->saddr = *(struct in6_addr *)n->primary_key;
 
 	skb_pull(reply, sizeof(struct ipv6hdr));
-	skb_set_transport_header(reply, 0);
+	skb_reset_transport_header(reply);
 
 	na = (struct nd_msg *)skb_put(reply, sizeof(*na) + na_olen);
 
-- 
1.8.3.1
