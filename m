From: Flavio Leitner <fleitner@redhat.com>
Subject: [PATCH] net: reset gso header when the copied skb is linearized
Date: Mon, 25 Oct 2010 20:23:18 -0200
Message-ID: <1288045398-3110-1-git-send-email-fleitner@redhat.com>
Cc: Flavio Leitner <fleitner@redhat.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22911 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752674Ab0JYWXe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Oct 2010 18:23:34 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o9PMNYkX008362
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 25 Oct 2010 18:23:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The gso header is incorrect when the copied skb is
linearized. This patch creates another helper function
to copy the gso header when it is appropriated

Signed-off-by: Flavio Leitner <fleitner@redhat.com>
---
 net/core/skbuff.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 104f844..54a2d3a 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -649,6 +649,12 @@ static void copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 	if (skb_mac_header_was_set(new))
 		new->mac_header	      += offset;
 #endif
+}
+
+static void copy_skb_header_gso(struct sk_buff *new, const struct sk_buff *old)
+{
+	copy_skb_header(new, old);
+
 	skb_shinfo(new)->gso_size = skb_shinfo(old)->gso_size;
 	skb_shinfo(new)->gso_segs = skb_shinfo(old)->gso_segs;
 	skb_shinfo(new)->gso_type = skb_shinfo(old)->gso_type;
@@ -740,7 +746,7 @@ struct sk_buff *pskb_copy(struct sk_buff *skb, gfp_t gfp_mask)
 		skb_clone_fraglist(n);
 	}
 
-	copy_skb_header(n, skb);
+	copy_skb_header_gso(n, skb);
 out:
 	return n;
 }
-- 
1.7.3.1

