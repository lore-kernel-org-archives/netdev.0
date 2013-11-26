From: Tom Herbert <therbert@google.com>
Subject: [PATCH 02/17] net: Add function to set the rxhash
Date: Mon, 25 Nov 2013 21:48:17 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1311252146100.22983@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f74.google.com ([209.85.212.74]:62117 "EHLO
	mail-vb0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752670Ab3KZFsS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 00:48:18 -0500
Received: by mail-vb0-f74.google.com with SMTP id w8so555701vbj.5
        for <netdev@vger.kernel.org>; Mon, 25 Nov 2013 21:48:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function skb_set_rxash was added for drivers to call to set
the rxhash in an skb. The type of hash is also specified as
a parameter (L2, L3, L4, or unknown type).

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/skbuff.h | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 76d3aa9..25f190e 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -703,6 +703,20 @@ unsigned int skb_find_text(struct sk_buff *skb, unsigned int from,
 			   unsigned int to, struct ts_config *config,
 			   struct ts_state *state);
 
+enum rxhash_types {
+	RXHASH_TYPE_NONE,	/* Undefined type */
+	RXHASH_TYPE_L2,		/* Uses L2 information (addresses) */
+	RXHASH_TYPE_L3,		/* Uses L3 information */
+	RXHASH_TYPE_L4,		/* Uses L4 information (ports) */
+};
+
+static inline void
+skb_set_rxhash(struct sk_buff *skb, __u32 hash, enum rxhash_types type)
+{
+	skb->l4_rxhash = (type == RXHASH_TYPE_L4);
+	skb->rxhash = hash;
+}
+
 void __skb_get_rxhash(struct sk_buff *skb);
 static inline __u32 skb_get_rxhash(struct sk_buff *skb)
 {
-- 
1.8.4.1
