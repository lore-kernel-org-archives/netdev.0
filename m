From: Tom Herbert <therbert@google.com>
Subject: [PATCH 4/4 v3] net: Add utility function to copy skb hash
Date: Sun, 15 Dec 2013 22:16:29 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1312152212230.20838@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f73.google.com ([209.85.128.73]:52148 "EHLO
	mail-qe0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752701Ab3LPGQa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 01:16:30 -0500
Received: by mail-qe0-f73.google.com with SMTP id 5so443819qeb.4
        for <netdev@vger.kernel.org>; Sun, 15 Dec 2013 22:16:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds skb_copy_hash to copy rxhash and l4_rxhash from one skb to another.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/skbuff.h | 6 ++++++
 net/core/skbuff.c      | 3 +--
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 9984695..06bedeb 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -764,6 +764,12 @@ static inline void skb_clear_hash_if_not_l4(struct sk_buff *skb)
 		skb_clear_hash(skb);
 }
 
+static inline void skb_copy_hash(struct sk_buff *to, const struct sk_buff *from)
+{
+	to->rxhash = from->rxhash;
+	to->l4_rxhash = from->l4_rxhash;
+};
+
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
 static inline unsigned char *skb_end_pointer(const struct sk_buff *skb)
 {
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 06e72d3..2b6b863 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -712,9 +712,8 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 	new->inner_network_header = old->inner_network_header;
 	new->inner_mac_header = old->inner_mac_header;
 	skb_dst_copy(new, old);
-	new->rxhash		= old->rxhash;
+	skb_copy_hash(new, old);
 	new->ooo_okay		= old->ooo_okay;
-	new->l4_rxhash		= old->l4_rxhash;
 	new->no_fcs		= old->no_fcs;
 	new->encapsulation	= old->encapsulation;
 #ifdef CONFIG_XFRM
-- 
1.8.5.1
