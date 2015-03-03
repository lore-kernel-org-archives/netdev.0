From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv1 1/2] xen-netback: return correct ethtool stats
Date: Tue, 3 Mar 2015 16:26:10 +0000
Message-ID: <1425399971-27630-2-git-send-email-david.vrabel@citrix.com>
References: <1425399971-27630-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Vrabel <david.vrabel@citrix.com>,
	<xen-devel@lists.xenproject.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:58634 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757162AbbCCQaV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Mar 2015 11:30:21 -0500
In-Reply-To: <1425399971-27630-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use correct pointer arithmetic to get the pointer to each stat.

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
---
 drivers/net/xen-netback/interface.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index f38227a..3aa8648 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -340,12 +340,11 @@ static void xenvif_get_ethtool_stats(struct net_device *dev,
 	unsigned int num_queues = vif->num_queues;
 	int i;
 	unsigned int queue_index;
-	struct xenvif_stats *vif_stats;
 
 	for (i = 0; i < ARRAY_SIZE(xenvif_stats); i++) {
 		unsigned long accum = 0;
 		for (queue_index = 0; queue_index < num_queues; ++queue_index) {
-			vif_stats = &vif->queues[queue_index].stats;
+			void *vif_stats = &vif->queues[queue_index].stats;
 			accum += *(unsigned long *)(vif_stats + xenvif_stats[i].offset);
 		}
 		data[i] = accum;
-- 
1.7.10.4
