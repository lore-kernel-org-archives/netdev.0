From: emmanuel.grumbach@intel.com
Subject: [PATCH] net: skb_trim explicitely check the linearity instead of data_len
Date: Sun, 22 May 2011 08:46:09 +0300
Message-ID: <1306043169-26659-1-git-send-email-emmanuel.grumbach@intel.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Emmanuel Grumbach <emmanuel.grumbach@intel.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:5037 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751252Ab1EVFqN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 May 2011 01:46:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emmanuel Grumbach <emmanuel.grumbach@intel.com>

The purpose of the check on data_len is to check linearity, so use the inline
helper for this. No overhead and more explicit.

Signed-off-by: Emmanuel Grumbach <emmanuel.grumbach@intel.com>
---
 include/linux/skbuff.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index bf221d6..a4f680c 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1439,7 +1439,7 @@ extern int ___pskb_trim(struct sk_buff *skb, unsigned int len);
 
 static inline void __skb_trim(struct sk_buff *skb, unsigned int len)
 {
-	if (unlikely(skb->data_len)) {
+	if (unlikely(skb_is_nonlinear(skb))) {
 		WARN_ON(1);
 		return;
 	}
-- 
1.7.1

---------------------------------------------------------------------
Intel Israel (74) Limited

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.

