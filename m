From: Vitaly Bordug <vitb@kernel.crashing.org>
Subject: [PATCH 2/2] [FS_ENET] Add polling support
Date: Tue, 18 Sep 2007 20:05:35 +0400
Message-ID: <20070918160535.13525.28254.stgit@localhost.localdomain>
References: <20070918160527.13525.80935.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:53423 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759433AbXIRQFs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Sep 2007 12:05:48 -0400
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linuxppc-dev@ozlabs.org
In-Reply-To: <20070918160527.13525.80935.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Vitaly Bordug <vitb@kernel.crashing.org>

---

 drivers/net/fs_enet/fs_enet-main.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)


diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index 927cd9e..0e2d2b2 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -61,6 +61,9 @@ module_param(fs_enet_debug, int, 0);
 MODULE_PARM_DESC(fs_enet_debug,
 		 "Freescale bitmapped debugging message enable value");
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void fs_enet_netpoll(struct net_device *dev);
+#endif
 
 static void fs_set_multicast_list(struct net_device *dev)
 {
@@ -1049,6 +1052,10 @@ static struct net_device *fs_init_instance(struct device *dev,
 	ndev->stop = fs_enet_close;
 	ndev->get_stats = fs_enet_get_stats;
 	ndev->set_multicast_list = fs_set_multicast_list;
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+       ndev->poll_controller = fs_enet_netpoll;
+#endif
 	if (fpi->use_napi) {
 		ndev->poll = fs_enet_rx_napi;
 		ndev->weight = fpi->napi_weight;
@@ -1275,6 +1282,15 @@ static void __exit fs_cleanup(void)
 	cleanup_immap();
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void fs_enet_netpoll(struct net_device *dev)
+{
+       disable_irq(dev->irq);
+       fs_enet_interrupt(dev->irq, dev, NULL);
+       enable_irq(dev->irq);
+}
+#endif
+
 /**************************************************************************************/
 
 module_init(fs_init);

