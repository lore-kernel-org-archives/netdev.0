From: xiaohui.xin@intel.com
Subject: [RFC][PATCH v4 12/18] To skip GRO if buffer is external.
Date: Sun, 25 Apr 2010 17:19:59 +0800
Message-ID: <1272187206-18534-12-git-send-email-xiaohui.xin@intel.com>
References: <1272187206-18534-1-git-send-email-xiaohui.xin@intel.com>
 <1272187206-18534-2-git-send-email-xiaohui.xin@intel.com>
 <1272187206-18534-3-git-send-email-xiaohui.xin@intel.com>
 <1272187206-18534-4-git-send-email-xiaohui.xin@intel.com>
 <1272187206-18534-5-git-send-email-xiaohui.xin@intel.com>
 <1272187206-18534-6-git-send-email-xiaohui.xin@intel.com>
 <1272187206-18534-7-git-send-email-xiaohui.xin@intel.com>
 <1272187206-18534-8-git-send-email-xiaohui.xin@intel.com>
 <1272187206-18534-9-git-send-email-xiaohui.xin@intel.com>
 <1272187206-18534-10-git-send-email-xiaohui.xin@intel.com>
 <1272187206-18534-11-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, jdike@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1272187206-18534-11-git-send-email-xiaohui.xin@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xin Xiaohui <xiaohui.xin@intel.com>

Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
Signed-off-by: Zhao Yu <yzhao81@gmail.com>
Reviewed-by: Jeff Dike <jdike@linux.intel.com>
---
 net/core/dev.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 3e3ad23..f275c44 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2780,6 +2780,10 @@ enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 	if (skb_is_gso(skb) || skb_has_frags(skb))
 		goto normal;
 
+	/* currently GRO is not supported by mediate passthru */
+	if (dev_is_mpassthru(skb->dev))
+		goto normal;
+
 	rcu_read_lock();
 	list_for_each_entry_rcu(ptype, head, list) {
 		if (ptype->type != type || ptype->dev || !ptype->gro_receive)
-- 
1.5.4.4
