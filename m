From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net-next 01/12] net: add dst_get_noref and refdst_ptr helpers
Date: Wed,  6 Mar 2013 10:42:11 +0200
Message-ID: <1362559342-18784-2-git-send-email-ja@ssi.bg>
References: <1362559342-18784-1-git-send-email-ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:44779 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751469Ab3CFImJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Mar 2013 03:42:09 -0500
In-Reply-To: <1362559342-18784-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Needed to hide refdst details.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/dst.h |   14 +++++++++++++-
 1 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 853cda1..967f42a 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -264,10 +264,22 @@ static inline struct dst_entry *dst_clone(struct dst_entry *dst)
 
 extern void dst_release(struct dst_entry *dst);
 
+/* Get noref version of dst */
+static inline struct dst_entry *dst_get_noref(struct dst_entry *dst)
+{
+	return (struct dst_entry *) ((unsigned long) dst | SKB_DST_NOREF);
+}
+
+/* Return dst pointer from refdst */
+static inline struct dst_entry *refdst_ptr(unsigned long refdst)
+{
+	return (struct dst_entry *)(refdst & SKB_DST_PTRMASK);
+}
+
 static inline void refdst_drop(unsigned long refdst)
 {
 	if (!(refdst & SKB_DST_NOREF))
-		dst_release((struct dst_entry *)(refdst & SKB_DST_PTRMASK));
+		dst_release(refdst_ptr(refdst));
 }
 
 /**
-- 
1.7.3.4
