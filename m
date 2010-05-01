From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [PATCH v21 093/100] c/r: Add checkpoint and collect hooks to net_device_ops
Date: Sat,  1 May 2010 10:16:15 -0400
Message-ID: <1272723382-19470-94-git-send-email-orenl@cs.columbia.edu>
References: <1272723382-19470-1-git-send-email-orenl@cs.columbia.edu>
Cc: containers@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>,
	Matt Helsley <matthltc@us.ibm.com>,
	Pavel Emelyanov <xemul@openvz.org>,
	Dan Smith <danms@us.ibm.com>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tarap.cc.columbia.edu ([128.59.29.7]:64423 "EHLO
	tarap.cc.columbia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932898Ab0EAOin (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 May 2010 10:38:43 -0400
In-Reply-To: <1272723382-19470-1-git-send-email-orenl@cs.columbia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Smith <danms@us.ibm.com>

These will be implemented per-driver by those that support such
operations.

Cc: netdev@vger.kernel.org
Signed-off-by: Dan Smith <danms@us.ibm.com>
Acked-by: David S. Miller <davem@davemloft.net>
Acked-by: Serge Hallyn <serue@us.ibm.com>
Acked-by: Oren Laadan <orenl@cs.columbia.edu>
---
 include/linux/netdevice.h |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index fa8b476..9f6de34 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -691,6 +691,12 @@ struct net_device_ops {
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
1.6.3.3

