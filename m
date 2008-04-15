From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 3/8][SIT]: Use proper net in hash-lookup functions.
Date: Tue, 15 Apr 2008 17:31:36 +0400
Message-ID: <4804AE38.1090808@openvz.org>
References: <4804ACFA.1040003@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:54212 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755294AbYDOM5Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 08:57:16 -0400
In-Reply-To: <4804ACFA.1040003@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace introduced in the previous patch init_net stubs 
with the proper net pointer.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv6/sit.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 66cf0be..e85ddcd 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -444,7 +444,7 @@ static int ipip6_err(struct sk_buff *skb, u32 info)
 	err = -ENOENT;
 
 	read_lock(&ipip6_lock);
-	t = ipip6_tunnel_lookup(&init_net, iph->daddr, iph->saddr);
+	t = ipip6_tunnel_lookup(dev_net(skb->dev), iph->daddr, iph->saddr);
 	if (t == NULL || t->parms.iph.daddr == 0)
 		goto out;
 
@@ -564,7 +564,7 @@ static int ipip6_rcv(struct sk_buff *skb)
 	iph = ip_hdr(skb);
 
 	read_lock(&ipip6_lock);
-	if ((tunnel = ipip6_tunnel_lookup(&init_net,
+	if ((tunnel = ipip6_tunnel_lookup(dev_net(skb->dev),
 					iph->saddr, iph->daddr)) != NULL) {
 		secpath_reset(skb);
 		skb->mac_header = skb->network_header;
-- 
1.5.3.4

