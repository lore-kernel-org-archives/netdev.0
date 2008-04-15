From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 4/8][IPIP]: Use proper net in hash-lookup functions.
Date: Tue, 15 Apr 2008 16:33:45 +0400
Message-ID: <4804A0A9.8090106@openvz.org>
References: <48049E9C.1020207@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:42875 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751022AbYDOL71 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 07:59:27 -0400
In-Reply-To: <48049E9C.1020207@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the part#2 of the previous patch - get the proper
net for these functions.

I make it in a separate patch, so that this change does not
get lost in a large previous patch.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv4/ipip.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index bc4d4cb..da71470 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -318,7 +318,7 @@ static int ipip_err(struct sk_buff *skb, u32 info)
 	err = -ENOENT;
 
 	read_lock(&ipip_lock);
-	t = ipip_tunnel_lookup(&init_net, iph->daddr, iph->saddr);
+	t = ipip_tunnel_lookup(dev_net(skb->dev), iph->daddr, iph->saddr);
 	if (t == NULL || t->parms.iph.daddr == 0)
 		goto out;
 
@@ -478,7 +478,7 @@ static int ipip_rcv(struct sk_buff *skb)
 	const struct iphdr *iph = ip_hdr(skb);
 
 	read_lock(&ipip_lock);
-	if ((tunnel = ipip_tunnel_lookup(&init_net,
+	if ((tunnel = ipip_tunnel_lookup(dev_net(skb->dev),
 					iph->saddr, iph->daddr)) != NULL) {
 		if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb)) {
 			read_unlock(&ipip_lock);
-- 
1.5.3.4

