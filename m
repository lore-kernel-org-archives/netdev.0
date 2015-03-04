From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv2 1/3] xen-netback: return correct ethtool stats
Date: Wed, 4 Mar 2015 11:14:46 +0000
Message-ID: <1425467688-12846-2-git-send-email-david.vrabel@citrix.com>
References: <1425467688-12846-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Vrabel <david.vrabel@citrix.com>,
	<xen-devel@lists.xenproject.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:27909 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932903AbbCDLO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 06:14:59 -0500
In-Reply-To: <1425467688-12846-1-git-send-email-david.vrabel@citrix.com>
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
