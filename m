From: Vitaly Bordug <vitb@kernel.crashing.org>
Subject: [PATCH 1/2] [FS_ENET] TX stuff should use fep->tx_lock,
	instead of fep->lock.
Date: Tue, 18 Sep 2007 20:05:27 +0400
Message-ID: <20070918160527.13525.80935.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:53420 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757914AbXIRQFn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Sep 2007 12:05:43 -0400
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linuxppc-dev@ozlabs.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Vitaly Bordug <vitb@kernel.crashing.org>

---

 drivers/net/fs_enet/fs_enet-main.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)


diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index a4a2a0e..927cd9e 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -348,7 +348,7 @@ static void fs_enet_tx(struct net_device *dev)
 	int dirtyidx, do_wake, do_restart;
 	u16 sc;
 
-	spin_lock(&fep->lock);
+	spin_lock(&fep->tx_lock);
 	bdp = fep->dirty_tx;
 
 	do_wake = do_restart = 0;
@@ -428,7 +428,7 @@ static void fs_enet_tx(struct net_device *dev)
 	if (do_restart)
 		(*fep->ops->tx_restart)(dev);
 
-	spin_unlock(&fep->lock);
+	spin_unlock(&fep->tx_lock);
 
 	if (do_wake)
 		netif_wake_queue(dev);
@@ -826,7 +826,9 @@ static int fs_enet_close(struct net_device *dev)
 	phy_stop(fep->phydev);
 
 	spin_lock_irqsave(&fep->lock, flags);
+	spin_lock(&fep->tx_lock);
 	(*fep->ops->stop)(dev);
+	spin_unlock(&fep->tx_lock);
 	spin_unlock_irqrestore(&fep->lock, flags);
 
 	/* release any irqs */

