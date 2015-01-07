From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 4/6] vxlan: Fail build if VXLAN header is misdefined
Date: Wed,  7 Jan 2015 03:05:39 +0100
Message-ID: <761bed48e52520bbdd43d8420b4e46ba2cde07e6.1420594925.git.tgraf@suug.ch>
References: <cover.1420594925.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: davem@davemloft.net, jesse@nicira.com, stephen@networkplumber.org,
	pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:42826 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757358AbbAGCFz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 21:05:55 -0500
In-Reply-To: <cover.1420594925.git.tgraf@suug.ch>
In-Reply-To: <cover.1420594925.git.tgraf@suug.ch>
References: <cover.1420594925.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Due to the complexity of struct vxlanhdr, protect against unwanted
and undesired changes by failing the build if the size of the struct
changes.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 drivers/net/vxlan.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 2b75c62..293d524 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2842,6 +2842,8 @@ static int __init vxlan_init_module(void)
 {
 	int rc;
 
+	BUILD_BUG_ON(sizeof(struct vxlanhdr) != 8);
+
 	vxlan_wq = alloc_workqueue("vxlan", 0, 0);
 	if (!vxlan_wq)
 		return -ENOMEM;
-- 
1.9.3
