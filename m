From: Tom Gundersen <teg@jklm.no>
Subject: [PATCH v7 22/33] net: hamradio - set name assign type
Date: Thu, 10 Jul 2014 10:17:27 +0200
Message-ID: <1404980258-30853-23-git-send-email-teg@jklm.no>
References: <1404980258-30853-1-git-send-email-teg@jklm.no>
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	David Herrmann <dh.herrmann@gmail.com>,
	Kay Sievers <kay@vrfy.org>, Tom Gundersen <teg@jklm.no>,
	Thomas Sailer <t.sailer@alumni.ethz.ch>,
	Joerg Reuter <jreuter@yaina.de>,
	Jean-Paul Roubelat <jpr@f6fbb.org>,
	Wenliang Fan <fanwlexca@gmail.com>, linux-hams@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:63709 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752230AbaGJISs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 04:18:48 -0400
Received: by mail-lb0-f176.google.com with SMTP id w7so5707602lbi.7
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2014 01:18:46 -0700 (PDT)
In-Reply-To: <1404980258-30853-1-git-send-email-teg@jklm.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The hamradio devices are created the same way with the same names on module
init time so should therefore be PREDICTABLE rather than ENUM.

Signed-off-by: Tom Gundersen <teg@jklm.no>
Cc: Thomas Sailer <t.sailer@alumni.ethz.ch>
Cc: Joerg Reuter <jreuter@yaina.de>
Cc: Jean-Paul Roubelat <jpr@f6fbb.org>
Cc: Wenliang Fan <fanwlexca@gmail.com>
Cc: linux-hams@vger.kernel.org
---
 drivers/net/hamradio/baycom_par.c     |  3 ++-
 drivers/net/hamradio/baycom_ser_fdx.c |  3 ++-
 drivers/net/hamradio/baycom_ser_hdx.c |  3 ++-
 drivers/net/hamradio/dmascc.c         |  1 +
 drivers/net/hamradio/hdlcdrv.c        |  3 ++-
 drivers/net/hamradio/scc.c            | 11 ++++++-----
 drivers/net/hamradio/yam.c            |  2 +-
 include/linux/hdlcdrv.h               |  1 +
 8 files changed, 17 insertions(+), 10 deletions(-)

diff --git a/drivers/net/hamradio/baycom_par.c b/drivers/net/hamradio/baycom_par.c
index acb6369..234df52 100644
--- a/drivers/net/hamradio/baycom_par.c
+++ b/drivers/net/hamradio/baycom_par.c
@@ -513,7 +513,8 @@ static int __init init_baycompar(void)
 
 		dev = hdlcdrv_register(&par96_ops,
 				       sizeof(struct baycom_state),
-				       ifname, iobase[i], 0, 0);
+				       ifname, NET_NAME_PREDICTABLE,
+				       iobase[i], 0, 0);
 		if (IS_ERR(dev)) 
 			break;
 
diff --git a/drivers/net/hamradio/baycom_ser_fdx.c b/drivers/net/hamradio/baycom_ser_fdx.c
index 636b65c..c7786fc 100644
--- a/drivers/net/hamradio/baycom_ser_fdx.c
+++ b/drivers/net/hamradio/baycom_ser_fdx.c
@@ -648,7 +648,8 @@ static int __init init_baycomserfdx(void)
 
 		dev = hdlcdrv_register(&ser12_ops, 
 				       sizeof(struct baycom_state),
-				       ifname, iobase[i], irq[i], 0);
+				       ifname, NET_NAME_PREDICTABLE,
+				       iobase[i], irq[i], 0);
 		if (IS_ERR(dev)) 
 			break;
 
diff --git a/drivers/net/hamradio/baycom_ser_hdx.c b/drivers/net/hamradio/baycom_ser_hdx.c
index f9a8976..8d9f85f 100644
--- a/drivers/net/hamradio/baycom_ser_hdx.c
+++ b/drivers/net/hamradio/baycom_ser_hdx.c
@@ -676,7 +676,8 @@ static int __init init_baycomserhdx(void)
 
 		dev = hdlcdrv_register(&ser12_ops, 
 				       sizeof(struct baycom_state),
-				       ifname, iobase[i], irq[i], 0);
+				       ifname, NET_NAME_PREDICTABLE,
+				       iobase[i], irq[i], 0);
 		if (IS_ERR(dev)) 
 			break;
 
diff --git a/drivers/net/hamradio/dmascc.c b/drivers/net/hamradio/dmascc.c
index 0fad408..d7918ce 100644
--- a/drivers/net/hamradio/dmascc.c
+++ b/drivers/net/hamradio/dmascc.c
@@ -577,6 +577,7 @@ static int __init setup_adapter(int card_base, int type, int n)
 		INIT_WORK(&priv->rx_work, rx_bh);
 		dev->ml_priv = priv;
 		sprintf(dev->name, "dmascc%i", 2 * n + i);
+		dev->name_assign_type =  NET_NAME_ENUM;
 		dev->base_addr = card_base;
 		dev->irq = irq;
 		dev->netdev_ops = &scc_netdev_ops;
diff --git a/drivers/net/hamradio/hdlcdrv.c b/drivers/net/hamradio/hdlcdrv.c
index c67a272..13cbfde 100644
--- a/drivers/net/hamradio/hdlcdrv.c
+++ b/drivers/net/hamradio/hdlcdrv.c
@@ -687,6 +687,7 @@ static void hdlcdrv_setup(struct net_device *dev)
 /* --------------------------------------------------------------------- */
 struct net_device *hdlcdrv_register(const struct hdlcdrv_ops *ops,
 				    unsigned int privsize, const char *ifname,
+				    unsigned char name_assign_type,
 				    unsigned int baseaddr, unsigned int irq, 
 				    unsigned int dma) 
 {
@@ -699,7 +700,7 @@ struct net_device *hdlcdrv_register(const struct hdlcdrv_ops *ops,
 	if (privsize < sizeof(struct hdlcdrv_state))
 		privsize = sizeof(struct hdlcdrv_state);
 
-	dev = alloc_netdev(privsize, ifname, NET_NAME_UNKNOWN, hdlcdrv_setup);
+	dev = alloc_netdev(privsize, ifname, name_assign_type, hdlcdrv_setup);
 	if (!dev)
 		return ERR_PTR(-ENOMEM);
 
diff --git a/drivers/net/hamradio/scc.c b/drivers/net/hamradio/scc.c
index 57be9e0..a4fe9ba 100644
--- a/drivers/net/hamradio/scc.c
+++ b/drivers/net/hamradio/scc.c
@@ -202,7 +202,7 @@ static void init_channel(struct scc_channel *scc);
 static void scc_key_trx (struct scc_channel *scc, char tx);
 static void scc_init_timer(struct scc_channel *scc);
 
-static int scc_net_alloc(const char *name, struct scc_channel *scc);
+static int scc_net_alloc(const char *name, unsigned char name_assign_type, struct scc_channel *scc);
 static void scc_net_setup(struct net_device *dev);
 static int scc_net_open(struct net_device *dev);
 static int scc_net_close(struct net_device *dev);
@@ -1510,12 +1510,13 @@ static void z8530_init(void)
  * Allocate device structure, err, instance, and register driver
  */
 
-static int scc_net_alloc(const char *name, struct scc_channel *scc)
+static int scc_net_alloc(const char *name, unsigned char name_assign_type,
+			 struct scc_channel *scc)
 {
 	int err;
 	struct net_device *dev;
 
-	dev = alloc_netdev(0, name, NET_NAME_UNKNOWN, scc_net_setup);
+	dev = alloc_netdev(0, name, name_assign_type, scc_net_setup);
 	if (!dev) 
 		return -ENOMEM;
 
@@ -1815,7 +1816,7 @@ static int scc_net_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 					request_region(SCC_Info[2*Nchips+chan].ctrl, 1, "scc ctrl");
 					request_region(SCC_Info[2*Nchips+chan].data, 1, "scc data");
 					if (Nchips+chan != 0 &&
-					    scc_net_alloc(device_name, 
+					    scc_net_alloc(device_name, NET_NAME_PREDICTABLE,
 							  &SCC_Info[2*Nchips+chan]))
 					    return -EINVAL;
 				}
@@ -2111,7 +2112,7 @@ static int __init scc_init_driver (void)
 	sprintf(devname,"%s0", SCC_DriverName);
 	
 	rtnl_lock();
-	if (scc_net_alloc(devname, SCC_Info)) {
+	if (scc_net_alloc(devname, NET_NAME_PREDICTABLE, SCC_Info)) {
 		rtnl_unlock();
 		printk(KERN_ERR "z8530drv: cannot initialize module\n");
 		return -EIO;
diff --git a/drivers/net/hamradio/yam.c b/drivers/net/hamradio/yam.c
index 717433c..3e73e4d 100644
--- a/drivers/net/hamradio/yam.c
+++ b/drivers/net/hamradio/yam.c
@@ -1147,7 +1147,7 @@ static int __init yam_init_driver(void)
 		sprintf(name, "yam%d", i);
 		
 		dev = alloc_netdev(sizeof(struct yam_port), name,
-				   NET_NAME_UNKNOWN, yam_setup);
+				   NET_NAME_PREDICTABLE, yam_setup);
 		if (!dev) {
 			pr_err("yam: cannot allocate net device\n");
 			err = -ENOMEM;
diff --git a/include/linux/hdlcdrv.h b/include/linux/hdlcdrv.h
index be3be25..2cb8295 100644
--- a/include/linux/hdlcdrv.h
+++ b/include/linux/hdlcdrv.h
@@ -264,6 +264,7 @@ void hdlcdrv_transmitter(struct net_device *, struct hdlcdrv_state *);
 void hdlcdrv_arbitrate(struct net_device *, struct hdlcdrv_state *);
 struct net_device *hdlcdrv_register(const struct hdlcdrv_ops *ops,
 				    unsigned int privsize, const char *ifname,
+				    unsigned char name_assign_type,
 				    unsigned int baseaddr, unsigned int irq, 
 				    unsigned int dma);
 void hdlcdrv_unregister(struct net_device *dev);
-- 
1.9.3
