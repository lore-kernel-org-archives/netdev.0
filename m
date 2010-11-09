From: xiaohui.xin@intel.com
Subject: [PATCH v15 09/17] Don't do skb recycle, if device use external buffer.
Date: Tue,  9 Nov 2010 17:03:14 +0800
Message-ID: <97fa0298a51dc64626ff44e1756d09b94e4697df.1289280886.git.xiaohui.xin@intel.com>
References: <1289293402-4791-1-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, herbert@gondor.apana.org.au,
	jdike@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:40024 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754037Ab0KIIll (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Nov 2010 03:41:41 -0500
In-Reply-To: <1289293402-4791-1-git-send-email-xiaohui.xin@intel.com>
In-Reply-To: <fc6e95d63a2c62aaf77f8ded22fc43ccefcdbbff.1289280885.git.xiaohui.xin@intel.com>
References: <fc6e95d63a2c62aaf77f8ded22fc43ccefcdbbff.1289280885.git.xiaohui.xin@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Xiaohui <xiaohui.xin@intel.com>

Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
Signed-off-by: Zhao Yu <yzhao81new@gmail.com>
Reviewed-by: Jeff Dike <jdike@linux.intel.com>
---
 net/core/skbuff.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 3d81113..075f4c5 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -557,6 +557,12 @@ bool skb_recycle_check(struct sk_buff *skb, int skb_size)
 	if (skb_shared(skb) || skb_cloned(skb))
 		return false;
 
+	/* if the device wants to do mediate passthru, the skb may
+	 * get external buffer, so don't recycle
+	 */
+	if (dev_is_mpassthru(skb->dev))
+		return 0;
+
 	skb_release_head_state(skb);
 
 	shinfo = skb_shinfo(skb);
-- 
1.7.3

