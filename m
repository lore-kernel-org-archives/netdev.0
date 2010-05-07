From: xiaohui.xin@intel.com
Subject: [RFC][PATCH v5 13/19] To skip GRO if buffer is external currently.
Date: Fri,  7 May 2010 17:35:00 +0800
Message-ID: <1273224906-4874-14-git-send-email-xiaohui.xin@intel.com>
References: <1273224906-4874-1-git-send-email-xiaohui.xin@intel.com>
 <1273224906-4874-2-git-send-email-xiaohui.xin@intel.com>
 <1273224906-4874-3-git-send-email-xiaohui.xin@intel.com>
 <1273224906-4874-4-git-send-email-xiaohui.xin@intel.com>
 <1273224906-4874-5-git-send-email-xiaohui.xin@intel.com>
 <1273224906-4874-6-git-send-email-xiaohui.xin@intel.com>
 <1273224906-4874-7-git-send-email-xiaohui.xin@intel.com>
 <1273224906-4874-8-git-send-email-xiaohui.xin@intel.com>
 <1273224906-4874-9-git-send-email-xiaohui.xin@intel.com>
 <1273224906-4874-10-git-send-email-xiaohui.xin@intel.com>
 <1273224906-4874-11-git-send-email-xiaohui.xin@intel.com>
 <1273224906-4874-12-git-send-email-xiaohui.xin@intel.com>
 <1273224906-4874-13-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, jdike@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:55769 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754975Ab0EGJaM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 May 2010 05:30:12 -0400
In-Reply-To: <1273224906-4874-13-git-send-email-xiaohui.xin@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Xiaohui <xiaohui.xin@intel.com>

Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
Signed-off-by: Zhao Yu <yzhao81new@gmail.com>
Reviewed-by: Jeff Dike <jdike@linux.intel.com>
---
 net/core/dev.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index dc2f225..6c6b2fe 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2787,6 +2787,10 @@ enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
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

