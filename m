From: xiaohui.xin@intel.com
Subject: [RFC PATCH v10 09/16] Don't do skb recycle, if device use external buffer.
Date: Sat, 11 Sep 2010 17:53:02 +0800
Message-ID: <1284198789-5358-10-git-send-email-xiaohui.xin@intel.com>
References: <1284198789-5358-1-git-send-email-xiaohui.xin@intel.com>
 <1284198789-5358-2-git-send-email-xiaohui.xin@intel.com>
 <1284198789-5358-3-git-send-email-xiaohui.xin@intel.com>
 <1284198789-5358-4-git-send-email-xiaohui.xin@intel.com>
 <1284198789-5358-5-git-send-email-xiaohui.xin@intel.com>
 <1284198789-5358-6-git-send-email-xiaohui.xin@intel.com>
 <1284198789-5358-7-git-send-email-xiaohui.xin@intel.com>
 <1284198789-5358-8-git-send-email-xiaohui.xin@intel.com>
 <1284198789-5358-9-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, herbert@gondor.apana.org.au,
	jdike@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1284198789-5358-9-git-send-email-xiaohui.xin@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xin Xiaohui <xiaohui.xin@intel.com>

    Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
    Signed-off-by: Zhao Yu <yzhao81new@gmail.com>
    Reviewed-by: Jeff Dike <jdike@linux.intel.com>
---
 net/core/skbuff.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index bbf4707..9b156bb 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -565,6 +565,12 @@ int skb_recycle_check(struct sk_buff *skb, int skb_size)
 	if (skb_shared(skb) || skb_cloned(skb))
 		return 0;
 
+	/* if the device wants to do mediate passthru, the skb may
+	 * get external buffer, so don't recycle
+	 */
+	if (dev_is_mpassthru(skb->dev))
+		return 0;
+
 	skb_release_head_state(skb);
 	shinfo = skb_shinfo(skb);
 	atomic_set(&shinfo->dataref, 1);
-- 
1.5.4.4
