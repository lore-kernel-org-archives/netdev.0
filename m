From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 1/4] Use the skb_set_queue_mapping where appropriate
Date: Fri, 19 Oct 2007 13:00:52 +0400
Message-ID: <47187244.1010603@openvz.org>
References: <471871E5.7060900@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:35376 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756961AbXJSJBE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2007 05:01:04 -0400
In-Reply-To: <471871E5.7060900@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There's already such a helper to initialize this field.
Use it.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/core/dev.c b/net/core/dev.c
index 38b03da..8726589 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1661,7 +1661,7 @@ gso:
 		q = dev->qdisc;
 		if (q->enqueue) {
 			/* reset queue_mapping to zero */
-			skb->queue_mapping = 0;
+			skb_set_queue_mapping(skb, 0);
 			rc = q->enqueue(skb, q);
 			qdisc_run(dev);
 			spin_unlock(&dev->queue_lock);
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 8cae60c..d4d9a36 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2603,8 +2603,7 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 	skb->network_header = skb->tail;
 	skb->transport_header = skb->network_header + sizeof(struct iphdr);
 	skb_put(skb, sizeof(struct iphdr) + sizeof(struct udphdr));
-	skb->queue_mapping = pkt_dev->cur_queue_map;
-
+	skb_set_queue_mapping(skb, pkt_dev->cur_queue_map);
 	iph = ip_hdr(skb);
 	udph = udp_hdr(skb);
 
@@ -2941,8 +2940,7 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
 	skb->network_header = skb->tail;
 	skb->transport_header = skb->network_header + sizeof(struct ipv6hdr);
 	skb_put(skb, sizeof(struct ipv6hdr) + sizeof(struct udphdr));
-	skb->queue_mapping = pkt_dev->cur_queue_map;
-
+	skb_set_queue_mapping(skb, pkt_dev->cur_queue_map);
 	iph = ipv6_hdr(skb);
 	udph = udp_hdr(skb);
 

