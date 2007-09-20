From: Scott Wood <scottwood@freescale.com>
Subject: [PATCH 3/9] fs_enet: Don't share the interrupt.
Date: Thu, 20 Sep 2007 17:01:18 -0500
Message-ID: <20070920220118.GC28784@loki.buserror.net>
References: <20070920220043.GA28769@loki.buserror.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:35133 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752726AbXITWB5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 18:01:57 -0400
Content-Disposition: inline
In-Reply-To: <20070920220043.GA28769@loki.buserror.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This driver can't handle an interrupt immediately after request_irq
(making it fail with CONFIG_DEBUG_SHIRQ), and has unshared interrupts
on all hardware I'm aware of.

Signed-off-by: Scott Wood <scottwood@freescale.com>
---
 drivers/net/fs_enet/fs_enet-main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index f261b90..da79a45 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -667,7 +667,7 @@ static int fs_request_irq(struct net_device *dev, int irq, const char *name,
 	struct fs_enet_private *fep = netdev_priv(dev);
 
 	(*fep->ops->pre_request_irq)(dev, irq);
-	return request_irq(irq, irqf, IRQF_SHARED, name, dev);
+	return request_irq(irq, irqf, 0, name, dev);
 }
 
 static void fs_free_irq(struct net_device *dev, int irq)
-- 
1.5.3.1

