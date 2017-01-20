From: Geliang Tang <geliangtang@gmail.com>
Subject: [PATCH] 6lowpan: use rb_entry()
Date: Fri, 20 Jan 2017 22:36:53 +0800
Message-ID: <c6a809ea5820242a4ae126b03cdcd910a36e5cae.1484817152.git.geliangtang@gmail.com>
Cc: Geliang Tang <geliangtang@gmail.com>,
        linux-bluetooth@vger.kernel.org, linux-wpan@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alexander Aring <aar@pengutronix.de>,
        Jukka Rissanen <jukka.rissanen@linux.intel.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36061 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752319AbdATOlR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 09:41:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To make the code clearer, use rb_entry() instead of container_of() to
deal with rbtree.

Signed-off-by: Geliang Tang <geliangtang@gmail.com>
---
 net/6lowpan/nhc.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/6lowpan/nhc.c b/net/6lowpan/nhc.c
index 7008d53..4fa2fdd 100644
--- a/net/6lowpan/nhc.c
+++ b/net/6lowpan/nhc.c
@@ -27,8 +27,8 @@ static int lowpan_nhc_insert(struct lowpan_nhc *nhc)
 
 	/* Figure out where to put new node */
 	while (*new) {
-		struct lowpan_nhc *this = container_of(*new, struct lowpan_nhc,
-						       node);
+		struct lowpan_nhc *this = rb_entry(*new, struct lowpan_nhc,
+						   node);
 		int result, len_dif, len;
 
 		len_dif = nhc->idlen - this->idlen;
@@ -69,8 +69,8 @@ static struct lowpan_nhc *lowpan_nhc_by_nhcid(const struct sk_buff *skb)
 	const u8 *nhcid_skb_ptr = skb->data;
 
 	while (node) {
-		struct lowpan_nhc *nhc = container_of(node, struct lowpan_nhc,
-						      node);
+		struct lowpan_nhc *nhc = rb_entry(node, struct lowpan_nhc,
+						  node);
 		u8 nhcid_skb_ptr_masked[LOWPAN_NHC_MAX_ID_LEN];
 		int result, i;
 
-- 
2.9.3
