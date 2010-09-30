From: xiaohui.xin@intel.com
Subject: [PATCH v12 01/17] Add a new structure for skb buffer from external.
Date: Thu, 30 Sep 2010 22:04:18 +0800
Message-ID: <59d8a50047ee01e26658fd676d26c0162b79e5fd.1285853725.git.xiaohui.xin@intel.com>
References: <1285855474-12110-1-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, herbert@gondor.apana.org.au,
	jdike@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:30013 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756130Ab0I3Nqv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Sep 2010 09:46:51 -0400
In-Reply-To: <1285855474-12110-1-git-send-email-xiaohui.xin@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Xiaohui <xiaohui.xin@intel.com>

Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
Signed-off-by: Zhao Yu <yzhao81new@gmail.com>
Reviewed-by: Jeff Dike <jdike@linux.intel.com>
---
 include/linux/skbuff.h |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 124f90c..74af06c 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -203,6 +203,15 @@ struct skb_shared_info {
 	void *		destructor_arg;
 };
 
+/* The structure is for a skb which pages may point to
+ * an external buffer, which is not allocated from kernel space.
+ * It also contains a destructor for itself.
+ */
+struct skb_ext_page {
+	struct		page *page;
+	void		(*dtor)(struct skb_ext_page *);
+};
+
 /* We divide dataref into two halves.  The higher 16 bits hold references
  * to the payload part of skb->data.  The lower 16 bits hold references to
  * the entire skb->data.  A clone of a headerless skb holds the length of
-- 
1.7.3

