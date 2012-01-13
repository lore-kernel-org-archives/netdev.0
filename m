From: Wei Liu <wei.liu2@citrix.com>
Subject: [RFC PATCH 4/6] netback: add module get/put operations along with vif connect/disconnect.
Date: Fri, 13 Jan 2012 16:59:07 +0000
Message-ID: <1326473949-22389-5-git-send-email-wei.liu2@citrix.com>
References: <1326473949-22389-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Wei Liu <wei.liu2@citrix.com>
To: ian.campbell@citrix.com, konrad.wilk@oracle.com,
	xen-devel@lists.xensource.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:11856 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752344Ab2AMQ7h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jan 2012 11:59:37 -0500
In-Reply-To: <1326473949-22389-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If there is vif running and user unloads netback, it will certainly
cause problems.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/interface.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 93cb212..3126028 100644
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
