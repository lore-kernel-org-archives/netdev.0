From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 1/6] net: pack skb_shared_info more efficiently
Date: Thu, 5 Jan 2012 17:13:39 +0000
Message-ID: <1325783624-14601-1-git-send-email-ian.campbell@citrix.com>
References: <1325783399.25206.413.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:4867 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758159Ab2AERNt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jan 2012 12:13:49 -0500
In-Reply-To: <1325783399.25206.413.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nr_frags can be 8 bits since 256 is plenty of fragments. This allows it to be
packed with tx_flags.

Also by moving ip6_frag_id and dataref (both 4 bytes) next to each other we can
avoid a hole between ip6_frag_id and frag_list on 64 bit systems.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
---
 include/linux/skbuff.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index f47f0c3..50db9b0 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -242,15 +242,15 @@ struct ubuf_info {
  * the end of the header data, ie. at skb->end.
  */
 struct skb_shared_info {
-	unsigned short	nr_frags;
+	unsigned char	nr_frags;
+	__u8		tx_flags;
 	unsigned short	gso_size;
 	/* Warning: this field is not always filled in (UFO)! */
 	unsigned short	gso_segs;
 	unsigned short  gso_type;
-	__be32          ip6_frag_id;
-	__u8		tx_flags;
 	struct sk_buff	*frag_list;
 	struct skb_shared_hwtstamps hwtstamps;
+	__be32          ip6_frag_id;
 
 	/*
 	 * Warning : all fields before dataref are cleared in __alloc_skb()
-- 
1.7.2.5
