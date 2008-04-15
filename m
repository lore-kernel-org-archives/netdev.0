From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 3/8][GRE]: Use proper net in hash-lookup functions.
Date: Tue, 15 Apr 2008 16:55:27 +0400
Message-ID: <4804A5BF.6010508@openvz.org>
References: <4804A374.9040505@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:33624 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751324AbYDOMVH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 08:21:07 -0400
In-Reply-To: <4804A374.9040505@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the part#2 of the patch #2 - get the proper net for
these functions. This change in a separate patch in order not
to get lost in a large previous patch.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv4/ip_gre.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 6209ab3..1a17c5b 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -377,7 +377,7 @@ static void ipgre_err(struct sk_buff *skb, u32 info)
 	}
 
 	read_lock(&ipgre_lock);
-	t = ipgre_tunnel_lookup(&init_net, iph->daddr, iph->saddr,
+	t = ipgre_tunnel_lookup(dev_net(skb->dev), iph->daddr, iph->saddr,
 			(flags&GRE_KEY) ?
 			*(((__be32*)p) + (grehlen>>2) - 1) : 0);
 	if (t == NULL || t->parms.iph.daddr == 0 ||
@@ -612,7 +612,7 @@ static int ipgre_rcv(struct sk_buff *skb)
 	}
 
 	read_lock(&ipgre_lock);
-	if ((tunnel = ipgre_tunnel_lookup(&init_net,
+	if ((tunnel = ipgre_tunnel_lookup(dev_net(skb->dev),
 					iph->saddr, iph->daddr, key)) != NULL) {
 		secpath_reset(skb);
 
-- 
1.5.3.4

