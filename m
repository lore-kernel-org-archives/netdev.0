From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH 18/21] net: caif: convert to using IFF_NO_QUEUE
Date: Tue, 18 Aug 2015 10:30:46 +0200
Message-ID: <1439886649-24166-19-git-send-email-phil@nwl.cc>
References: <1439886649-24166-1-git-send-email-phil@nwl.cc>
 <1439886649-24166-2-git-send-email-phil@nwl.cc>
 <1439886649-24166-3-git-send-email-phil@nwl.cc>
 <1439886649-24166-4-git-send-email-phil@nwl.cc>
 <1439886649-24166-5-git-send-email-phil@nwl.cc>
 <1439886649-24166-6-git-send-email-phil@nwl.cc>
 <1439886649-24166-7-git-send-email-phil@nwl.cc>
 <1439886649-24166-8-git-send-email-phil@nwl.cc>
 <1439886649-24166-9-git-send-email-phil@nwl.cc>
 <1439886649-24166-10-git-send-email-phil@nwl.cc>
 <1439886649-24166-11-git-send-email-phil@nwl.cc>
 <1439886649-24166-12-git-send-email-phil@nwl.cc>
 <1439886649-24166-13-git-send-email-phil@nwl.cc>
 <1439886649-24166-14-git-send-email-phil@nwl.cc>
 <1439886649-24166-15-git-send-email-phil@nwl.cc>
 <1439886649-24166-16-git-send-email-phil@nwl.cc>
 <1439886649-24166-17-git-send-email-phil@nwl.cc>
 <1439886649-24166-18-git-send-email-phil@nwl.cc>
Cc: brouer@redhat.com, davem@davemloft.net,
	Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:51357 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751119AbbHRIa4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 04:30:56 -0400
In-Reply-To: <1439886649-24166-18-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
Cc: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>
---
 drivers/net/caif/caif_hsi.c    | 2 +-
 drivers/net/caif/caif_serial.c | 2 +-
 drivers/net/caif/caif_spi.c    | 2 +-
 drivers/net/wan/hdlc_fr.c      | 2 +-
 net/caif/caif_dev.c            | 2 +-
 5 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/caif/caif_hsi.c b/drivers/net/caif/caif_hsi.c
index b3b922a..615c65d 100644
--- a/drivers/net/caif/caif_hsi.c
+++ b/drivers/net/caif/caif_hsi.c
@@ -1120,7 +1120,7 @@ static void cfhsi_setup(struct net_device *dev)
 	dev->type = ARPHRD_CAIF;
 	dev->flags = IFF_POINTOPOINT | IFF_NOARP;
 	dev->mtu = CFHSI_MAX_CAIF_FRAME_SZ;
-	dev->tx_queue_len = 0;
+	dev->priv_flags |= IFF_NO_QUEUE;
 	dev->destructor = free_netdev;
 	dev->netdev_ops = &cfhsi_netdevops;
 	for (i = 0; i < CFHSI_PRIO_LAST; ++i)
diff --git a/drivers/net/caif/caif_serial.c b/drivers/net/caif/caif_serial.c
index 9da0653..c2dea49 100644
--- a/drivers/net/caif/caif_serial.c
+++ b/drivers/net/caif/caif_serial.c
@@ -427,7 +427,7 @@ static void caifdev_setup(struct net_device *dev)
 	dev->type = ARPHRD_CAIF;
 	dev->flags = IFF_POINTOPOINT | IFF_NOARP;
 	dev->mtu = CAIF_MAX_MTU;
-	dev->tx_queue_len = 0;
+	dev->priv_flags |= IFF_NO_QUEUE;
 	dev->destructor = free_netdev;
 	skb_queue_head_init(&serdev->head);
 	serdev->common.link_select = CAIF_LINK_LOW_LATENCY;
diff --git a/drivers/net/caif/caif_spi.c b/drivers/net/caif/caif_spi.c
index 72ea9ff..de39620 100644
--- a/drivers/net/caif/caif_spi.c
+++ b/drivers/net/caif/caif_spi.c
@@ -710,7 +710,7 @@ static void cfspi_setup(struct net_device *dev)
 	dev->netdev_ops = &cfspi_ops;
 	dev->type = ARPHRD_CAIF;
 	dev->flags = IFF_NOARP | IFF_POINTOPOINT;
-	dev->tx_queue_len = 0;
+	dev->priv_flags |= IFF_NO_QUEUE;
 	dev->mtu = SPI_MAX_PAYLOAD_SIZE;
 	dev->destructor = free_netdev;
 	skb_queue_head_init(&cfspi->qhead);
diff --git a/drivers/net/wan/hdlc_fr.c b/drivers/net/wan/hdlc_fr.c
index 3ebed1c..e92aaf6 100644
--- a/drivers/net/wan/hdlc_fr.c
+++ b/drivers/net/wan/hdlc_fr.c
@@ -1096,7 +1096,7 @@ static int fr_add_pvc(struct net_device *frad, unsigned int dlci, int type)
 	}
 	dev->netdev_ops = &pvc_ops;
 	dev->mtu = HDLC_MAX_MTU;
-	dev->tx_queue_len = 0;
+	dev->priv_flags |= IFF_NO_QUEUE;
 	dev->ml_priv = pvc;
 
 	if (register_netdevice(dev) != 0) {
diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index edbca46..d730a0f 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -177,7 +177,7 @@ static int transmit(struct cflayer *layer, struct cfpkt *pkt)
 	skb->protocol = htons(ETH_P_CAIF);
 
 	/* Check if we need to handle xoff */
-	if (likely(caifd->netdev->tx_queue_len == 0))
+	if (likely(caifd->netdev->priv_flags & IFF_NO_QUEUE))
 		goto noxoff;
 
 	if (unlikely(caifd->xoff))
-- 
2.1.2
