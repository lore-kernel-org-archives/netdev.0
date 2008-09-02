From: Brian Haley <brian.haley@hp.com>
Subject: [Resend] [PATCH] bonding: change some __constant_htons() to htons()
Date: Tue, 02 Sep 2008 10:08:08 -0400
Message-ID: <48BD48C8.1090806@hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060905050507080500030407"
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
To: jgarzik@pobox.com, fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:32167 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751248AbYIBOIo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2008 10:08:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060905050507080500030407
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Resending since I didn't see any responses from the first try.

Change __constant_htons() to htons() in the bonding driver, it should
only be used for initializers.

-Brian

Signed-off-by: Brian Haley <brian.haley@hp.com>
---


--------------060905050507080500030407
Content-Type: text/x-patch;
 name="bonding-htons.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="bonding-htons.patch"

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index b211486..3d39278 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -710,7 +710,7 @@ static struct slave *rlb_arp_xmit(struct sk_buff *skb, struct bonding *bond)
 	struct arp_pkt *arp = arp_pkt(skb);
 	struct slave *tx_slave = NULL;
 
-	if (arp->op_code == __constant_htons(ARPOP_REPLY)) {
+	if (arp->op_code == htons(ARPOP_REPLY)) {
 		/* the arp must be sent on the selected
 		* rx channel
 		*/
@@ -719,7 +719,7 @@ static struct slave *rlb_arp_xmit(struct sk_buff *skb, struct bonding *bond)
 			memcpy(arp->mac_src,tx_slave->dev->dev_addr, ETH_ALEN);
 		}
 		dprintk("Server sent ARP Reply packet\n");
-	} else if (arp->op_code == __constant_htons(ARPOP_REQUEST)) {
+	} else if (arp->op_code == htons(ARPOP_REQUEST)) {
 		/* Create an entry in the rx_hashtbl for this client as a
 		 * place holder.
 		 * When the arp reply is received the entry will be updated
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index c792138..babe461 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3702,7 +3702,7 @@ static int bond_xmit_hash_policy_l23(struct sk_buff *skb,
 	struct ethhdr *data = (struct ethhdr *)skb->data;
 	struct iphdr *iph = ip_hdr(skb);
 
-	if (skb->protocol == __constant_htons(ETH_P_IP)) {
+	if (skb->protocol == htons(ETH_P_IP)) {
 		return ((ntohl(iph->saddr ^ iph->daddr) & 0xffff) ^
 			(data->h_dest[5] ^ bond_dev->dev_addr[5])) % count;
 	}
@@ -3723,8 +3723,8 @@ static int bond_xmit_hash_policy_l34(struct sk_buff *skb,
 	__be16 *layer4hdr = (__be16 *)((u32 *)iph + iph->ihl);
 	int layer4_xor = 0;
 
-	if (skb->protocol == __constant_htons(ETH_P_IP)) {
-		if (!(iph->frag_off & __constant_htons(IP_MF|IP_OFFSET)) &&
+	if (skb->protocol == htons(ETH_P_IP)) {
+		if (!(iph->frag_off & htons(IP_MF|IP_OFFSET)) &&
 		    (iph->protocol == IPPROTO_TCP ||
 		     iph->protocol == IPPROTO_UDP)) {
 			layer4_xor = ntohs((*layer4hdr ^ *(layer4hdr + 1)));


--------------060905050507080500030407--
