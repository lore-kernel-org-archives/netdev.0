From: Patrick McHardy <kaber@trash.net>
Subject: [SK_BUFF]: Fix missing offset adjustment in pskb_expand_head
Date: Sun, 08 Apr 2007 03:47:39 +0200
Message-ID: <461849BB.4090805@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070807090403020603040502"
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Kernel Netdev Mailing List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37376 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965379AbXDHBro (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Apr 2007 21:47:44 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070807090403020603040502
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

These patches fix two crashes I was getting with net-2.6.22
on 64 bit caused by missing skb header offset adjustments
when changing the headroom length.


--------------070807090403020603040502
Content-Type: text/plain;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

[SK_BUFF]: Fix missing offset adjustment in pskb_expand_head

Since we're increasing the headroom, the header offsets need to be
increased by the same amount as well.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit fb98b03719ad23840ca005edbba3c86ef1e3282c
tree 25821494e6032e487f3d197fa1392206b0004583
parent 5899a39783bd49bd6b926eaeafc16c7276620f63
author Patrick McHardy <kaber@trash.net> Sun, 08 Apr 2007 03:17:49 +0200
committer Patrick McHardy <kaber@trash.net> Sun, 08 Apr 2007 03:17:49 +0200

 net/core/skbuff.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index e60864e..5c9ee94 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -725,14 +725,15 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 	skb->data    += off;
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
 	skb->end      = size;
+	off           = nhead;
 #else
 	skb->end      = skb->head + size;
+#endif
 	/* {transport,network,mac}_header and tail are relative to skb->head */
 	skb->tail	      += off;
 	skb->transport_header += off;
 	skb->network_header   += off;
 	skb->mac_header	      += off;
-#endif
 	skb->cloned   = 0;
 	skb->nohdr    = 0;
 	atomic_set(&skb_shinfo(skb)->dataref, 1);

--------------070807090403020603040502--
