From: xiaohui.xin@intel.com
Subject: [RFC][PATCH v6 10/19] Don't do skb recycle, if device use external buffer.
Date: Fri, 21 May 2010 17:30:26 +0800
Message-ID: <1274434235-5929-11-git-send-email-xiaohui.xin@intel.com>
References: <1274434235-5929-1-git-send-email-xiaohui.xin@intel.com>
 <1274434235-5929-2-git-send-email-xiaohui.xin@intel.com>
 <1274434235-5929-3-git-send-email-xiaohui.xin@intel.com>
 <1274434235-5929-4-git-send-email-xiaohui.xin@intel.com>
 <1274434235-5929-5-git-send-email-xiaohui.xin@intel.com>
 <1274434235-5929-6-git-send-email-xiaohui.xin@intel.com>
 <1274434235-5929-7-git-send-email-xiaohui.xin@intel.com>
 <1274434235-5929-8-git-send-email-xiaohui.xin@intel.com>
 <1274434235-5929-9-git-send-email-xiaohui.xin@intel.com>
 <1274434235-5929-10-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, jdike@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1274434235-5929-10-git-send-email-xiaohui.xin@intel.com>
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
index 38d19d0..37587f0 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -553,6 +553,12 @@ int skb_recycle_check(struct sk_buff *skb, int skb_size)
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
