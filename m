From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] ehea: fix compilation
Date: Fri, 4 May 2007 00:04:00 +0400
Message-ID: <20070503200400.GD5836@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: acme@ghostprotocols.net, tklein@de.ibm.com, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:32623 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754052AbXECUD5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 16:03:57 -0400
Received: by ug-out-1314.google.com with SMTP id 44so524600uga
        for <netdev@vger.kernel.org>; Thu, 03 May 2007 13:03:55 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 Compile-tested only.

 drivers/net/ehea/ehea_main.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -1799,14 +1799,15 @@ static void ehea_xmit3(struct sk_buff *skb, struct net_device *dev,
 
 static inline int ehea_hash_skb(struct sk_buff *skb, int num_qps)
 {
+	struct iphdr *iph = ip_hdr(skb);
 	struct tcphdr *tcp;
 	u32 tmp;
 
 	if ((skb->protocol == htons(ETH_P_IP)) &&
-	    (skb->nh.iph->protocol == IPPROTO_TCP)) {
-		tcp = (struct tcphdr*)(skb->nh.raw + (skb->nh.iph->ihl * 4));
+	    (iph->protocol == IPPROTO_TCP)) {
+		tcp = (struct tcphdr*)(skb_network_header(skb) + iph->ihl * 4);
 		tmp = (tcp->source + (tcp->dest << 16)) % 31;
-		tmp += skb->nh.iph->daddr % 31;
+		tmp += iph->daddr % 31;
 		return tmp % num_qps;
 	}
 	else

