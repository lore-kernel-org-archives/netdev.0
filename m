From: Tom Gundersen <teg@jklm.no>
Subject: [PATCH v7 15/33] net: xen-netback - set name assign type
Date: Thu, 10 Jul 2014 10:17:20 +0200
Message-ID: <1404980258-30853-16-git-send-email-teg@jklm.no>
References: <1404980258-30853-1-git-send-email-teg@jklm.no>
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	David Herrmann <dh.herrmann@gmail.com>,
	Kay Sievers <kay@vrfy.org>, Tom Gundersen <teg@jklm.no>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>, xen-devel@lists.xenproject.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:50963 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752193AbaGJISc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 04:18:32 -0400
Received: by mail-lb0-f173.google.com with SMTP id s7so5881643lbd.32
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2014 01:18:31 -0700 (PDT)
In-Reply-To: <1404980258-30853-1-git-send-email-teg@jklm.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The name contains then xen handle, which is not guaranteed to be
stable between restarts, so label this NET_NAME_ENUM.

Signed-off-by: Tom Gundersen <teg@jklm.no>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: Wei Liu <wei.liu2@citrix.com>
Cc: xen-devel@lists.xenproject.org
---
 drivers/net/xen-netback/interface.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 793275d..da906d1 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -418,8 +418,8 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 	 * When the guest selects the desired number, it will be updated
 	 * via netif_set_real_num_*_queues().
 	 */
-	dev = alloc_netdev_mq(sizeof(struct xenvif), name, NET_NAME_UNKNOWN,
-			      ether_setup, xenvif_max_queues);
+	dev = alloc_netdev_mq(sizeof(struct xenvif), name, NET_NAME_ENUM, ether_setup,
+			      xenvif_max_queues);
 	if (dev == NULL) {
 		pr_warn("Could not allocate netdev for %s\n", name);
 		return ERR_PTR(-ENOMEM);
-- 
1.9.3
