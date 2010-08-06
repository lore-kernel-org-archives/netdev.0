From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/9] u32 classifier: fix sparse warnings
Date: Fri, 06 Aug 2010 12:35:51 -0700
Message-ID: <20100806193558.758205922@vyatta.com>
References: <20100806193548.007978639@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:35711 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761962Ab0HFTiH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Aug 2010 15:38:07 -0400
Content-Disposition: inline; filename=cls-u32-sparse.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The variable _data is used in asm-generic to define sections
which causes sparse warnings, so just rename the variable.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/sched/cls_u32.c	2010-08-06 11:41:06.974527973 -0700
+++ b/net/sched/cls_u32.c	2010-08-06 12:20:03.508295989 -0700
@@ -135,12 +135,12 @@ next_knode:
 
 		for (i = n->sel.nkeys; i>0; i--, key++) {
 			int toff = off + key->off + (off2 & key->offmask);
-			__be32 *data, _data;
+			__be32 *data, hdata;
 
 			if (skb_headroom(skb) + toff < 0)
 				goto out;
 
-			data = skb_header_pointer(skb, toff, 4, &_data);
+			data = skb_header_pointer(skb, toff, 4, &hdata);
 			if (!data)
 				goto out;
 			if ((*data ^ key->val) & key->mask) {
@@ -188,10 +188,10 @@ check_terminal:
 		ht = n->ht_down;
 		sel = 0;
 		if (ht->divisor) {
-			__be32 *data, _data;
+			__be32 *data, hdata;
 
 			data = skb_header_pointer(skb, off + n->sel.hoff, 4,
-						  &_data);
+						  &hdata);
 			if (!data)
 				goto out;
 			sel = ht->divisor & u32_hash_fold(*data, &n->sel,
@@ -203,11 +203,11 @@ check_terminal:
 		if (n->sel.flags&(TC_U32_OFFSET|TC_U32_VAROFFSET)) {
 			off2 = n->sel.off + 3;
 			if (n->sel.flags & TC_U32_VAROFFSET) {
-				__be16 *data, _data;
+				__be16 *data, hdata;
 
 				data = skb_header_pointer(skb,
 							  off + n->sel.offoff,
-							  2, &_data);
+							  2, &hdata);
 				if (!data)
 					goto out;
 				off2 += ntohs(n->sel.offmask & *data) >>


