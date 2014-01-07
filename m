From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] net: xfrm: xfrm_policy: fix inline not at beginning of declaration
Date: Tue,  7 Jan 2014 23:20:27 +0100
Message-ID: <1389133227-11086-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7071 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753914AbaAGWUb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jan 2014 17:20:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix three warnings related to:

  net/xfrm/xfrm_policy.c:1644:1: warning: 'inline' is not at beginning of declaration [-Wold-style-declaration]
  net/xfrm/xfrm_policy.c:1656:1: warning: 'inline' is not at beginning of declaration [-Wold-style-declaration]
  net/xfrm/xfrm_policy.c:1668:1: warning: 'inline' is not at beginning of declaration [-Wold-style-declaration]

Just removing the inline keyword is sufficient as the compiler will
decide on its own about inlining or not.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/xfrm/xfrm_policy.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index a7487f3..b390446 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1641,20 +1641,20 @@ free_dst:
 	goto out;
 }
 
-static int inline
-xfrm_dst_alloc_copy(void **target, const void *src, int size)
+static int xfrm_dst_alloc_copy(void **target, const void *src, int size)
 {
 	if (!*target) {
 		*target = kmalloc(size, GFP_ATOMIC);
 		if (!*target)
 			return -ENOMEM;
 	}
+
 	memcpy(*target, src, size);
 	return 0;
 }
 
-static int inline
-xfrm_dst_update_parent(struct dst_entry *dst, const struct xfrm_selector *sel)
+static int xfrm_dst_update_parent(struct dst_entry *dst,
+				  const struct xfrm_selector *sel)
 {
 #ifdef CONFIG_XFRM_SUB_POLICY
 	struct xfrm_dst *xdst = (struct xfrm_dst *)dst;
@@ -1665,8 +1665,8 @@ xfrm_dst_update_parent(struct dst_entry *dst, const struct xfrm_selector *sel)
 #endif
 }
 
-static int inline
-xfrm_dst_update_origin(struct dst_entry *dst, const struct flowi *fl)
+static int xfrm_dst_update_origin(struct dst_entry *dst,
+				  const struct flowi *fl)
 {
 #ifdef CONFIG_XFRM_SUB_POLICY
 	struct xfrm_dst *xdst = (struct xfrm_dst *)dst;
-- 
1.7.11.7
