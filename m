From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] cls_u32: fix sparse warnings
Date: Sun, 20 Feb 2011 18:14:23 -0800
Message-ID: <20110220181423.492594b7@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56777 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752100Ab1BUCOZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Feb 2011 21:14:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The variable _data is used in asm-generic to define sections
which causes sparse warnings, so just rename the variable.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 net/sched/cls_u32.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

--- a/net/sched/cls_u32.c	2011-02-20 17:50:45.469140817 -0800
+++ b/net/sched/cls_u32.c	2011-02-20 17:51:40.205778673 -0800
@@ -134,12 +134,12 @@ next_knode:
 
 		for (i = n->sel.nkeys; i > 0; i--, key++) {
 			int toff = off + key->off + (off2 & key->offmask);
-			__be32 *data, _data;
+			__be32 *data, hdata;
 
 			if (skb_headroom(skb) + toff > INT_MAX)
 				goto out;
 
-			data = skb_header_pointer(skb, toff, 4, &_data);
+			data = skb_header_pointer(skb, toff, 4, &hdata);
 			if (!data)
 				goto out;
 			if ((*data ^ key->val) & key->mask) {
@@ -187,10 +187,10 @@ check_terminal:
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
@@ -202,11 +202,11 @@ check_terminal:
 		if (n->sel.flags & (TC_U32_OFFSET | TC_U32_VAROFFSET)) {
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
