From: Seguier Regis <rseguier@e-teleport.net>
Subject: [PATCH] via-velocity : fix compilation warning.
Date: Thu,  9 Apr 2009 11:33:57 +0000
Message-ID: <1239276837-17085-1-git-send-email-rseguier@e-teleport.net>
Cc: Seguier Regis <rseguier@e-teleport.net>
To: romieu@fr.zoreil.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.e-teleport.net ([213.190.64.162]:50042 "EHLO
	smtp.e-teleport.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933677AbZDIK3R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2009 06:29:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix this warning:
drivers/net/via-velocity.c:1924: warning: passing argument 2 of 'request_irq' from incompatible pointer type

Signed-off-by: Seguier Regis <rseguier@e-teleport.net>
---
 drivers/net/via-velocity.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index fb53ef8..754a4b1 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -377,7 +377,7 @@ static void velocity_print_info(struct velocity_info *vptr);
 static int velocity_open(struct net_device *dev);
 static int velocity_change_mtu(struct net_device *dev, int mtu);
 static int velocity_xmit(struct sk_buff *skb, struct net_device *dev);
-static int velocity_intr(int irq, void *dev_instance);
+static irqreturn_t velocity_intr(int irq, void *dev_instance);
 static void velocity_set_multi(struct net_device *dev);
 static struct net_device_stats *velocity_get_stats(struct net_device *dev);
 static int velocity_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
@@ -2215,7 +2215,7 @@ out:
  *	efficiently as possible.
  */
 
-static int velocity_intr(int irq, void *dev_instance)
+static irqreturn_t velocity_intr(int irq, void *dev_instance)
 {
 	struct net_device *dev = dev_instance;
 	struct velocity_info *vptr = netdev_priv(dev);
-- 
1.6.1.rc2

