From: Insu Yun <wuninsu@gmail.com>
Subject: [PATCH] xen-netback: correctly check failed allocation
Date: Thu, 15 Oct 2015 18:02:28 +0000
Message-ID: <1444932148-15633-1-git-send-email-wuninsu@gmail.com>
Cc: taesoo@gatech.edu, yeongjin.jang@gatech.edu, insu@gatech.edu,
	Insu Yun <wuninsu@gmail.com>
To: ian.campbell@citrix.com, wei.liu2@citrix.com,
	xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f169.google.com ([209.85.160.169]:34478 "EHLO
	mail-yk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751661AbbJOSB1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 14:01:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since vzalloc can be failed in memory pressure,
writes -ENOMEM to xenstore to indicate error.

Signed-off-by: Insu Yun <wuninsu@gmail.com>
---
 drivers/net/xen-netback/xenbus.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index 929a6e7..56ebd82 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -788,6 +788,12 @@ static void connect(struct backend_info *be)
 	/* Use the number of queues requested by the frontend */
 	be->vif->queues = vzalloc(requested_num_queues *
 				  sizeof(struct xenvif_queue));
+	if (!be->vif->queues) {
+		xenbus_dev_fatal(dev, -ENOMEM,
+				 "allocating queues");
+		return;
+	}
+
 	be->vif->num_queues = requested_num_queues;
 	be->vif->stalled_queues = requested_num_queues;
 
-- 
1.9.1
