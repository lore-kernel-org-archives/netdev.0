From: xiaohui.xin@intel.com
Subject: [RFC][PATCH v5 01/19] Add a new structure for skb buffer from external.
Date: Fri,  7 May 2010 17:34:48 +0800
Message-ID: <1273224906-4874-2-git-send-email-xiaohui.xin@intel.com>
References: <1273224906-4874-1-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, jdike@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:55769 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755218Ab0EGJ3v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 May 2010 05:29:51 -0400
In-Reply-To: <1273224906-4874-1-git-send-email-xiaohui.xin@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Xiaohui <xiaohui.xin@intel.com>

Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
Signed-off-by: Zhao Yu <yzhao81new@gmail.com>
Reviewed-by: Jeff Dike <jdike@linux.intel.com>
---
 include/linux/skbuff.h |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 124f90c..cf309c9 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -203,6 +203,18 @@ struct skb_shared_info {
 	void *		destructor_arg;
 };
 
+/* The structure is for a skb which skb->data may point to
+ * an external buffer, which is not allocated from kernel space.
+ * Since the buffer is external, then the shinfo or frags are
+ * also extern too. It also contains a destructor for itself.
+ */
+struct skb_external_page {
+	u8              *start;
+	int             size;
+	struct skb_frag_struct *frags;
+	struct skb_shared_info *ushinfo;
+	void		(*dtor)(struct skb_external_page *);
+};
 /* We divide dataref into two halves.  The higher 16 bits hold references
  * to the payload part of skb->data.  The lower 16 bits hold references to
  * the entire skb->data.  A clone of a headerless skb holds the length of
-- 
1.5.4.4

