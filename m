From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next] skbuff: remove unused variable `doff'
Date: Tue, 10 May 2016 12:38:08 -0400
Message-ID: <20160510163808.GN13183@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, daniel@iogearbox.net,
	sowmini.varadhan@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:46992 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752341AbcEJQia (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 12:38:30 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are two instances of an unused variable, `doff' added by
commit 6fa01ccd8830 ("skbuff: Add pskb_extract() helper function")
in pskb_carve_inside_header() and pskb_carve_inside_nonlinear().
Remove these instances, they are not used.

Reported by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/core/skbuff.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 5586be9..f2b77e5 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4634,7 +4634,6 @@ static int pskb_carve_inside_header(struct sk_buff *skb, const u32 off,
 	int size = skb_end_offset(skb);
 	int new_hlen = headlen - off;
 	u8 *data;
-	int doff = 0;
 
 	size = SKB_DATA_ALIGN(size);
 
@@ -4674,13 +4673,11 @@ static int pskb_carve_inside_header(struct sk_buff *skb, const u32 off,
 		skb_free_head(skb);
 	}
 
-	doff = (data - skb->head);
 	skb->head = data;
 	skb->data = data;
 	skb->head_frag = 0;
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
 	skb->end = size;
-	doff = 0;
 #else
 	skb->end = skb->head + size;
 #endif
@@ -4761,7 +4758,6 @@ static int pskb_carve_inside_nonlinear(struct sk_buff *skb, const u32 off,
 	u8 *data;
 	const int nfrags = skb_shinfo(skb)->nr_frags;
 	struct skb_shared_info *shinfo;
-	int doff = 0;
 
 	size = SKB_DATA_ALIGN(size);
 
@@ -4816,13 +4812,11 @@ static int pskb_carve_inside_nonlinear(struct sk_buff *skb, const u32 off,
 	}
 	skb_release_data(skb);
 
-	doff = (data - skb->head);
 	skb->head = data;
 	skb->head_frag = 0;
 	skb->data = data;
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
 	skb->end = size;
-	doff = 0;
 #else
 	skb->end = skb->head + size;
 #endif
-- 
1.7.1
