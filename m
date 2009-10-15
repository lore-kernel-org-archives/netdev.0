From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH] iproute2: Add ll_index_to_addr function
Date: Thu, 15 Oct 2009 14:53:13 -0400
Message-ID: <1255632793-17779-1-git-send-email-david.ward@ll.mit.edu>
Cc: David Ward <david.ward@ll.mit.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from LLMAIL1.LL.MIT.EDU ([129.55.12.41]:48209 "EHLO ll.mit.edu"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933570AbZJOTZF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2009 15:25:05 -0400
Received: (from smtp@localhost)
	by ll.mit.edu (8.12.10/8.8.8) id n9FJ0jLM013268
	for <netdev@vger.kernel.org>; Thu, 15 Oct 2009 15:00:45 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After calling ll_init_map, all of the information stored in the link-layer map
can be retrieved by function calls (ll_index_to_*), except for the link-layer
address. This patch fills the gap by adding a ll_index_to_addr function.
Changes welcome.

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 include/ll_map.h |    2 ++
 lib/ll_map.c     |   21 +++++++++++++++++++++
 2 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/include/ll_map.h b/include/ll_map.h
index c4d5c6d..752b827 100644
--- a/include/ll_map.h
+++ b/include/ll_map.h
@@ -9,5 +9,7 @@ extern const char *ll_index_to_name(unsigned idx);
 extern const char *ll_idx_n2a(unsigned idx, char *buf);
 extern int ll_index_to_type(unsigned idx);
 extern unsigned ll_index_to_flags(unsigned idx);
+extern unsigned ll_index_to_addr(unsigned idx, unsigned char *addr,
+				 unsigned alen);
 
 #endif /* __LL_MAP_H__ */
diff --git a/lib/ll_map.c b/lib/ll_map.c
index c1d61a9..7c0bea2 100644
--- a/lib/ll_map.c
+++ b/lib/ll_map.c
@@ -134,6 +134,27 @@ unsigned ll_index_to_flags(unsigned idx)
 	return 0;
 }
 
+unsigned ll_index_to_addr(unsigned idx, unsigned char *addr,
+			  unsigned alen)
+{
+	struct idxmap *im;
+
+	if (idx == 0)
+		return 0;
+
+	for (im = idxmap[idx&0xF]; im; im = im->next) {
+		if (im->index == idx) {
+			if (alen > sizeof(im->addr))
+				alen = sizeof(im->addr);
+			if (alen > im->alen)
+				alen = im->alen;
+			memcpy(addr, im->addr, alen);
+			return alen;
+		}
+	}
+	return 0;
+}
+
 unsigned ll_name_to_index(const char *name)
 {
 	static char ncache[16];
-- 
1.5.5.6

