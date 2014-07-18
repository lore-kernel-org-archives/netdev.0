From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH net 4/4 v2] xen-netback: Fix pointer incrementation to avoid incorrect logging
Date: Fri, 18 Jul 2014 19:08:05 +0100
Message-ID: <1405706885-16763-5-git-send-email-zoltan.kiss@citrix.com>
References: <1405706885-16763-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <xen-devel@lists.xenproject.org>
To: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405706885-16763-1-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Due to this pointer is increased prematurely, the error log contains rubbish.

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
Reported-by: Armin Zentai <armin.zentai@ezit.hu>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: xen-devel@lists.xenproject.org
---
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index cca82de..72d8a6b 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1045,7 +1045,6 @@ static int xenvif_tx_check_gop(struct xenvif_queue *queue,
 
 	/* Check status of header. */
 	err = (*gopp_copy)->status;
-	(*gopp_copy)++;
 	if (unlikely(err)) {
 		if (net_ratelimit())
 			netdev_dbg(queue->vif->dev,
@@ -1058,6 +1057,7 @@ static int xenvif_tx_check_gop(struct xenvif_queue *queue,
 			xenvif_idx_release(queue, pending_idx,
 					   XEN_NETIF_RSP_ERROR);
 	}
+	(*gopp_copy)++;
 
 check_frags:
 	for (i = 0; i < nr_frags; i++, gop_map++) {
