From: Joe Perches <joe@perches.com>
Subject: [PATCH 21/62] gianfar: Use static const
Date: Sat, 20 Nov 2010 18:38:22 -0800
Message-ID: <e3ebafc0b5c921d2887c00678905d755f33d95d6.1290305776.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1665 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756447Ab0KUCkB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Nov 2010 21:40:01 -0500
In-Reply-To: <cover.1290305773.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

Changed gfar_set_mac_for_addr to take const *

Uncompiled.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/gianfar.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index d1bec62..45c4b7b 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -143,7 +143,8 @@ void gfar_halt(struct net_device *dev);
 static void gfar_halt_nodisable(struct net_device *dev);
 void gfar_start(struct net_device *dev);
 static void gfar_clear_exact_match(struct net_device *dev);
-static void gfar_set_mac_for_addr(struct net_device *dev, int num, u8 *addr);
+static void gfar_set_mac_for_addr(struct net_device *dev, int num,
+				  const u8 *addr);
 static int gfar_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 
 MODULE_AUTHOR("Freescale Semiconductor, Inc");
@@ -3094,10 +3095,10 @@ static void gfar_set_multi(struct net_device *dev)
 static void gfar_clear_exact_match(struct net_device *dev)
 {
 	int idx;
-	u8 zero_arr[MAC_ADDR_LEN] = {0,0,0,0,0,0};
+	static const u8 zero_arr[MAC_ADDR_LEN] = {0, 0, 0, 0, 0, 0};
 
 	for(idx = 1;idx < GFAR_EM_NUM + 1;idx++)
-		gfar_set_mac_for_addr(dev, idx, (u8 *)zero_arr);
+		gfar_set_mac_for_addr(dev, idx, zero_arr);
 }
 
 /* Set the appropriate hash bit for the given addr */
@@ -3132,7 +3133,8 @@ static void gfar_set_hash_for_addr(struct net_device *dev, u8 *addr)
 /* There are multiple MAC Address register pairs on some controllers
  * This function sets the numth pair to a given address
  */
-static void gfar_set_mac_for_addr(struct net_device *dev, int num, u8 *addr)
+static void gfar_set_mac_for_addr(struct net_device *dev, int num,
+				  const u8 *addr)
 {
 	struct gfar_private *priv = netdev_priv(dev);
 	struct gfar __iomem *regs = priv->gfargrp[0].regs;
-- 
1.7.3.2.245.g03276.dirty

