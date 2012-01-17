From: Wei Liu <wei.liu2@citrix.com>
Subject: [RFC PATCH V2 5/8] netback: add module get/put operations along with vif connect/disconnect.
Date: Tue, 17 Jan 2012 13:47:01 +0000
Message-ID: <1326808024-3744-6-git-send-email-wei.liu2@citrix.com>
References: <1326808024-3744-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: konrad.wilk@oracle.com, david.vrabel@citrix.com,
	paul.durrant@citrix.com, Wei Liu <wei.liu2@citrix.com>
To: ian.campbell@citrix.com, netdev@vger.kernel.org,
	xen-devel@lists.xensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:35366 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754174Ab2AQNsN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 08:48:13 -0500
In-Reply-To: <1326808024-3744-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If there is vif running and user unloads netback, it will certainly
cause problems -- guest's network interface just mysteriously stops
working.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/interface.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index dfc04f8..7c86187 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -323,6 +323,8 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
 	if (vif->irq)
 		return 0;
 
+	__module_get(THIS_MODULE);
+
 	err = xen_netbk_map_frontend_rings(vif, tx_ring_ref, rx_ring_ref);
 	if (err < 0)
 		goto err;
@@ -405,4 +407,6 @@ void xenvif_disconnect(struct xenvif *vif)
 	xen_netbk_unmap_frontend_rings(vif);
 
 	free_netdev(vif->dev);
+
+	module_put(THIS_MODULE);
 }
-- 
1.7.2.5
