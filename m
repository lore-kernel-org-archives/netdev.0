From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 10/19] netdev: convert pcmcia drivers to netdev_tx_t
Date: Mon, 31 Aug 2009 22:50:49 -0700
Message-ID: <20090901055129.407000999@vyatta.com>
References: <20090901055039.824876937@vyatta.com>
Cc: netdev@vger.kernel.org, linux-pcmcia@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:34274 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752805AbZIAGC6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2009 02:02:58 -0400
Content-Disposition: inline; filename=pcmcia-tx.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update all the pcmcia network drivers for netdev_tx_t.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 drivers/net/pcmcia/3c574_cs.c    |    6 ++++--
 drivers/net/pcmcia/3c589_cs.c    |    6 ++++--
 drivers/net/pcmcia/axnet_cs.c    |    6 ++++--
 drivers/net/pcmcia/fmvj18x_cs.c  |    6 ++++--
 drivers/net/pcmcia/nmclan_cs.c   |    6 ++++--
 drivers/net/pcmcia/smc91c92_cs.c |    6 ++++--
 drivers/net/pcmcia/xirc2ps_cs.c  |    5 +++--
 7 files changed, 27 insertions(+), 14 deletions(-)

--- a/drivers/net/pcmcia/3c574_cs.c	2009-08-31 16:17:52.881112862 -0700
+++ b/drivers/net/pcmcia/3c574_cs.c	2009-08-31 16:27:06.721110183 -0700
@@ -239,7 +239,8 @@ static void tc574_wait_for_completion(st
 static void tc574_reset(struct net_device *dev);
 static void media_check(unsigned long arg);
 static int el3_open(struct net_device *dev);
-static int el3_start_xmit(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t el3_start_xmit(struct sk_buff *skb,
+					struct net_device *dev);
 static irqreturn_t el3_interrupt(int irq, void *dev_id);
 static void update_stats(struct net_device *dev);
 static struct net_device_stats *el3_get_stats(struct net_device *dev);
@@ -778,7 +779,8 @@ static void pop_tx_status(struct net_dev
 	}
 }
 
-static int el3_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t el3_start_xmit(struct sk_buff *skb,
+					struct net_device *dev)
 {
 	unsigned int ioaddr = dev->base_addr;
 	struct el3_private *lp = netdev_priv(dev);
--- a/drivers/net/pcmcia/3c589_cs.c	2009-08-31 16:17:52.891086127 -0700
+++ b/drivers/net/pcmcia/3c589_cs.c	2009-08-31 16:27:06.721110183 -0700
@@ -149,7 +149,8 @@ static void tc589_reset(struct net_devic
 static void media_check(unsigned long arg);
 static int el3_config(struct net_device *dev, struct ifmap *map);
 static int el3_open(struct net_device *dev);
-static int el3_start_xmit(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t el3_start_xmit(struct sk_buff *skb,
+					struct net_device *dev);
 static irqreturn_t el3_interrupt(int irq, void *dev_id);
 static void update_stats(struct net_device *dev);
 static struct net_device_stats *el3_get_stats(struct net_device *dev);
@@ -604,7 +605,8 @@ static void pop_tx_status(struct net_dev
     }
 }
 
-static int el3_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t el3_start_xmit(struct sk_buff *skb,
+					struct net_device *dev)
 {
     unsigned int ioaddr = dev->base_addr;
     struct el3_private *priv = netdev_priv(dev);
--- a/drivers/net/pcmcia/axnet_cs.c	2009-08-31 16:17:52.901106674 -0700
+++ b/drivers/net/pcmcia/axnet_cs.c	2009-08-31 16:27:06.721110183 -0700
@@ -92,7 +92,8 @@ static void axnet_release(struct pcmcia_
 static int axnet_open(struct net_device *dev);
 static int axnet_close(struct net_device *dev);
 static int axnet_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
-static int axnet_start_xmit(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t axnet_start_xmit(struct sk_buff *skb,
+					  struct net_device *dev);
 static struct net_device_stats *get_stats(struct net_device *dev);
 static void set_multicast_list(struct net_device *dev);
 static void axnet_tx_timeout(struct net_device *dev);
@@ -1063,7 +1064,8 @@ static void axnet_tx_timeout(struct net_
  * Sends a packet to an 8390 network device.
  */
  
-static int axnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t axnet_start_xmit(struct sk_buff *skb,
+					  struct net_device *dev)
 {
 	long e8390_base = dev->base_addr;
 	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
--- a/drivers/net/pcmcia/nmclan_cs.c	2009-08-31 16:17:52.921089522 -0700
+++ b/drivers/net/pcmcia/nmclan_cs.c	2009-08-31 16:27:06.721110183 -0700
@@ -424,7 +424,8 @@ static void nmclan_reset(struct net_devi
 static int mace_config(struct net_device *dev, struct ifmap *map);
 static int mace_open(struct net_device *dev);
 static int mace_close(struct net_device *dev);
-static int mace_start_xmit(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t mace_start_xmit(struct sk_buff *skb,
+					 struct net_device *dev);
 static void mace_tx_timeout(struct net_device *dev);
 static irqreturn_t mace_interrupt(int irq, void *dev_id);
 static struct net_device_stats *mace_get_stats(struct net_device *dev);
@@ -937,7 +938,8 @@ static void mace_tx_timeout(struct net_d
   netif_wake_queue(dev);
 }
 
-static int mace_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t mace_start_xmit(struct sk_buff *skb,
+					 struct net_device *dev)
 {
   mace_private *lp = netdev_priv(dev);
   unsigned int ioaddr = dev->base_addr;
--- a/drivers/net/pcmcia/smc91c92_cs.c	2009-08-31 16:17:52.871089451 -0700
+++ b/drivers/net/pcmcia/smc91c92_cs.c	2009-08-31 16:27:06.731081353 -0700
@@ -288,7 +288,8 @@ static int smc_open(struct net_device *d
 static int smc_close(struct net_device *dev);
 static int smc_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 static void smc_tx_timeout(struct net_device *dev);
-static int smc_start_xmit(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t smc_start_xmit(struct sk_buff *skb,
+					struct net_device *dev);
 static irqreturn_t smc_interrupt(int irq, void *dev_id);
 static void smc_rx(struct net_device *dev);
 static void set_rx_mode(struct net_device *dev);
@@ -1370,7 +1371,8 @@ static void smc_tx_timeout(struct net_de
     netif_wake_queue(dev);
 }
 
-static int smc_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t smc_start_xmit(struct sk_buff *skb,
+					struct net_device *dev)
 {
     struct smc_private *smc = netdev_priv(dev);
     unsigned int ioaddr = dev->base_addr;
--- a/drivers/net/pcmcia/xirc2ps_cs.c	2009-08-31 16:17:52.881112862 -0700
+++ b/drivers/net/pcmcia/xirc2ps_cs.c	2009-08-31 16:27:06.731081353 -0700
@@ -352,7 +352,8 @@ typedef struct local_info_t {
 /****************
  * Some more prototypes
  */
-static int do_start_xmit(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t do_start_xmit(struct sk_buff *skb,
+				       struct net_device *dev);
 static void xirc_tx_timeout(struct net_device *dev);
 static void xirc2ps_tx_timeout_task(struct work_struct *work);
 static void set_addresses(struct net_device *dev);
@@ -1361,7 +1362,7 @@ xirc_tx_timeout(struct net_device *dev)
     schedule_work(&lp->tx_timeout_task);
 }
 
-static int
+static netdev_tx_t
 do_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
     local_info_t *lp = netdev_priv(dev);
--- a/drivers/net/pcmcia/fmvj18x_cs.c	2009-08-31 16:17:52.891086127 -0700
+++ b/drivers/net/pcmcia/fmvj18x_cs.c	2009-08-31 16:27:06.731081353 -0700
@@ -96,7 +96,8 @@ static void fmvj18x_detach(struct pcmcia
 static int fjn_config(struct net_device *dev, struct ifmap *map);
 static int fjn_open(struct net_device *dev);
 static int fjn_close(struct net_device *dev);
-static int fjn_start_xmit(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t fjn_start_xmit(struct sk_buff *skb,
+					struct net_device *dev);
 static irqreturn_t fjn_interrupt(int irq, void *dev_id);
 static void fjn_rx(struct net_device *dev);
 static void fjn_reset(struct net_device *dev);
@@ -856,7 +857,8 @@ static void fjn_tx_timeout(struct net_de
     netif_wake_queue(dev);
 }
 
-static int fjn_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t fjn_start_xmit(struct sk_buff *skb,
+					struct net_device *dev)
 {
     struct local_info_t *lp = netdev_priv(dev);
     unsigned int ioaddr = dev->base_addr;

-- 

