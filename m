From: Dan Smith <danms@us.ibm.com>
Subject: [PATCH 1/4] Add checkpoint and collect hooks to net_device_ops
Date: Tue,  9 Feb 2010 13:25:10 -0800
Message-ID: <1265750713-15749-2-git-send-email-danms@us.ibm.com>
References: <1265750713-15749-1-git-send-email-danms@us.ibm.com>
Cc: netdev@vger.kernel.org
To: containers@lists.osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stein.danplanet.com ([71.245.107.83]:45115 "EHLO
	stein.danplanet.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751482Ab0BIV1E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2010 16:27:04 -0500
In-Reply-To: <1265750713-15749-1-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These will be implemented per-driver by those that support such
operations.

Signed-off-by: Dan Smith <danms@us.ibm.com>
---
 include/linux/netdevice.h |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a3fccc8..415a791 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -673,6 +673,12 @@ struct net_device_ops {
 	int			(*ndo_fcoe_get_wwn)(struct net_device *dev,
 						    u64 *wwn, int type);
 #endif
+#ifdef CONFIG_CHECKPOINT
+	int			(*ndo_collect)(struct ckpt_ctx *ctx,
+					       struct net_device *dev);
+	int			(*ndo_checkpoint)(struct ckpt_ctx *ctx,
+						  struct net_device *dev);
+#endif
 };
 
 /*
-- 
1.6.2.5

