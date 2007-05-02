From: Thomas Klein <osstklei@de.ibm.com>
Subject: [PATCH] ehea: Fix skb header access
Date: Wed, 2 May 2007 16:07:05 +0200
Message-ID: <200705021607.05338.osstklei@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <ossthema@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <ossrosch@linux.vnet.ibm.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.uk.ibm.com ([195.212.29.140]:47423 "EHLO
	mtagate7.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993217AbXEBOHI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 10:07:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adapt to new skb header access functions.

Signed-off-by: Thomas Klein <tklein@de.ibm.com>
---


diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index c7a5614..7211648 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -1803,10 +1803,10 @@ static inline int ehea_hash_skb(struct s
 	u32 tmp;
 
 	if ((skb->protocol == htons(ETH_P_IP)) &&
-	    (skb->nh.iph->protocol == IPPROTO_TCP)) {
-		tcp = (struct tcphdr*)(skb->nh.raw + (skb->nh.iph->ihl * 4));
+	    (ip_hdr(skb)->protocol == IPPROTO_TCP)) {
+		tcp = (struct tcphdr*)(skb_network_header(skb) + (ip_hdr(skb)->ihl * 4));
 		tmp = (tcp->source + (tcp->dest << 16)) % 31;
-		tmp += skb->nh.iph->daddr % 31;
+		tmp += ip_hdr(skb)->daddr % 31;
 		return tmp % num_qps;
 	}
 	else


