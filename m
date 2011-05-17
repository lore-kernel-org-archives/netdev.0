From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH] xen: netback: use __CONST_RING_SIZE not __RING_SIZE
Date: Tue, 17 May 2011 10:59:48 +0100
Message-ID: <1305626388-11602-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Witold Baryluk <baryluk@smp.if.uj.edu.pl>
To: xen-devel@lists.xensource.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:55906 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754024Ab1EQJ7x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 05:59:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The later causes warnings with gcc 4.5+. __CONST_RING_SIZE was introduced in
667c78afaec0 to fix this but as netback wasn't upstream at the time it did not
benefit, hence:

  CC      drivers/net/xen-netback/netback.o
drivers/net/xen-netback/netback.c:110:37: warning: variably modified 'grant_copy_op' at file scope [enabled by default]
drivers/net/xen-netback/netback.c:111:30: warning: variably modified 'meta' at file scope [enabled by default]
drivers/net/xen-netback/netback.c: In function 'xen_netbk_rx_action':
drivers/net/xen-netback/netback.c:584:6: warning: variable 'irq' set but not used [-Wunused-but-set-variable]

Thanks to Witold Baryluk for pointing this out.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Witold Baryluk <baryluk@smp.if.uj.edu.pl>
---
 drivers/net/xen-netback/common.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 5d7bbf2..e85474e 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -109,8 +109,8 @@ struct xenvif {
 	wait_queue_head_t waiting_to_free;
 };
 
-#define XEN_NETIF_TX_RING_SIZE __RING_SIZE((struct xen_netif_tx_sring *)0, PAGE_SIZE)
-#define XEN_NETIF_RX_RING_SIZE __RING_SIZE((struct xen_netif_rx_sring *)0, PAGE_SIZE)
+#define XEN_NETIF_TX_RING_SIZE __CONST_RING_SIZE(xen_netif_tx, PAGE_SIZE)
+#define XEN_NETIF_RX_RING_SIZE __CONST_RING_SIZE(xen_netif_rx, PAGE_SIZE)
 
 struct xenvif *xenvif_alloc(struct device *parent,
 			    domid_t domid,
-- 
1.7.2.5

