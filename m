From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 04/19] convert hamradio drivers to netdev_txreturnt_t
Date: Mon, 31 Aug 2009 22:50:43 -0700
Message-ID: <20090901055128.780933432@vyatta.com>
References: <20090901055039.824876937@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, linux-hams@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:57435 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751781AbZIAF6t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2009 01:58:49 -0400
Content-Disposition: inline; filename=hamradio-tx.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 drivers/net/hamradio/6pack.c    |    2 +-
 drivers/net/hamradio/bpqether.c |    2 +-
 drivers/net/hamradio/hdlcdrv.c  |    3 ++-
 drivers/net/hamradio/mkiss.c    |    2 +-
 drivers/net/hamradio/scc.c      |    5 +++--
 drivers/net/hamradio/yam.c      |    3 ++-
 net/netrom/nr_dev.c             |    2 +-
 net/rose/rose_dev.c             |    2 +-
 8 files changed, 12 insertions(+), 9 deletions(-)

--- a/drivers/net/hamradio/6pack.c	2009-08-31 16:17:53.361102287 -0700
+++ b/drivers/net/hamradio/6pack.c	2009-08-31 16:25:07.641091845 -0700
@@ -242,7 +242,7 @@ out_drop:
 
 /* Encapsulate an IP datagram and kick it into a TTY queue. */
 
-static int sp_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t sp_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct sixpack *sp = netdev_priv(dev);
 
--- a/drivers/net/hamradio/bpqether.c	2009-08-31 16:17:53.371081489 -0700
+++ b/drivers/net/hamradio/bpqether.c	2009-08-31 16:25:07.641091845 -0700
@@ -247,7 +247,7 @@ drop:
 /*
  * 	Send an AX.25 frame via an ethernet interface
  */
-static int bpq_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t bpq_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct sk_buff *newskb;
 	unsigned char *ptr;
--- a/drivers/net/hamradio/hdlcdrv.c	2009-08-31 16:17:53.391086825 -0700
+++ b/drivers/net/hamradio/hdlcdrv.c	2009-08-31 16:25:30.961107719 -0700
@@ -399,7 +399,8 @@ void hdlcdrv_arbitrate(struct net_device
  * ===================== network driver interface =========================
  */
 
-static int hdlcdrv_send_packet(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t hdlcdrv_send_packet(struct sk_buff *skb,
+				       struct net_device *dev)
 {
 	struct hdlcdrv_state *sm = netdev_priv(dev);
 
--- a/drivers/net/hamradio/mkiss.c	2009-08-31 16:17:53.371081489 -0700
+++ b/drivers/net/hamradio/mkiss.c	2009-08-31 16:25:07.641091845 -0700
@@ -525,7 +525,7 @@ static void ax_encaps(struct net_device 
 }
 
 /* Encapsulate an AX.25 packet and kick it into a TTY queue. */
-static int ax_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t ax_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct mkiss *ax = netdev_priv(dev);
 
--- a/drivers/net/hamradio/scc.c	2009-08-31 16:17:53.361102287 -0700
+++ b/drivers/net/hamradio/scc.c	2009-08-31 16:25:50.851112803 -0700
@@ -209,7 +209,8 @@ static void scc_net_setup(struct net_dev
 static int scc_net_open(struct net_device *dev);
 static int scc_net_close(struct net_device *dev);
 static void scc_net_rx(struct scc_channel *scc, struct sk_buff *skb);
-static int scc_net_tx(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t scc_net_tx(struct sk_buff *skb,
+			      struct net_device *dev);
 static int scc_net_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd);
 static int scc_net_set_mac_address(struct net_device *dev, void *addr);
 static struct net_device_stats * scc_net_get_stats(struct net_device *dev);
@@ -1634,7 +1635,7 @@ static void scc_net_rx(struct scc_channe
 
 /* ----> transmit frame <---- */
 
-static int scc_net_tx(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t scc_net_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	struct scc_channel *scc = (struct scc_channel *) dev->ml_priv;
 	unsigned long flags;
--- a/drivers/net/hamradio/yam.c	2009-08-31 16:17:53.391086825 -0700
+++ b/drivers/net/hamradio/yam.c	2009-08-31 16:25:07.641091845 -0700
@@ -594,7 +594,8 @@ static void ptt_off(struct net_device *d
 	outb(PTT_OFF, MCR(dev->base_addr));
 }
 
-static int yam_send_packet(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t yam_send_packet(struct sk_buff *skb,
+					 struct net_device *dev)
 {
 	struct yam_port *yp = netdev_priv(dev);
 
--- a/net/netrom/nr_dev.c	2009-08-31 16:17:53.341113712 -0700
+++ b/net/netrom/nr_dev.c	2009-08-31 16:25:07.641091845 -0700
@@ -169,7 +169,7 @@ static int nr_close(struct net_device *d
 	return 0;
 }
 
-static int nr_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t nr_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct net_device_stats *stats = &dev->stats;
 	unsigned int len = skb->len;
--- a/net/rose/rose_dev.c	2009-08-31 16:17:53.351106882 -0700
+++ b/net/rose/rose_dev.c	2009-08-31 16:25:07.651107783 -0700
@@ -131,7 +131,7 @@ static int rose_close(struct net_device 
 	return 0;
 }
 
-static int rose_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t rose_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct net_device_stats *stats = &dev->stats;
 

-- 

