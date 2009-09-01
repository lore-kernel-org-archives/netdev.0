From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 15/19] 3com: convert drivers to netdev_tx_t
Date: Mon, 31 Aug 2009 22:50:54 -0700
Message-ID: <20090901055129.928421529@vyatta.com>
References: <20090901055039.824876937@vyatta.com>
Cc: netdev@vger.kernel.org, Paul Gortmaker <p_gortmaker@yahoo.com>,
	Philip Blundell <philb@gnu.org>,
	Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:34263 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751781AbZIAGAc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2009 02:00:32 -0400
Content-Disposition: inline; filename=3com.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
---
 drivers/net/3c501.c |    2 +-
 drivers/net/3c501.h |    2 +-
 drivers/net/3c505.c |    4 ++--
 drivers/net/3c507.c |    6 ++++--
 drivers/net/3c509.c |    4 ++--
 drivers/net/3c515.c |    8 ++++----
 drivers/net/3c523.c |    4 ++--
 drivers/net/3c527.c |    6 ++++--
 drivers/net/3c59x.c |   10 ++++++----
 9 files changed, 26 insertions(+), 20 deletions(-)

--- a/drivers/net/3c501.c	2009-08-31 16:17:52.491216521 -0700
+++ b/drivers/net/3c501.c	2009-08-31 16:44:45.491085901 -0700
@@ -409,7 +409,7 @@ static void el_timeout(struct net_device
  * no real choice.
  */
 
-static int el_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t el_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct net_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
--- a/drivers/net/3c505.c	2009-08-31 16:17:52.481106298 -0700
+++ b/drivers/net/3c505.c	2009-08-31 16:45:36.098453665 -0700
@@ -976,7 +976,7 @@ static int elp_open(struct net_device *d
  *
  ******************************************************/
 
-static bool send_packet(struct net_device *dev, struct sk_buff *skb)
+static netdev_tx_t send_packet(struct net_device *dev, struct sk_buff *skb)
 {
 	elp_device *adapter = netdev_priv(dev);
 	unsigned long target;
@@ -1067,7 +1067,7 @@ static void elp_timeout(struct net_devic
  *
  ******************************************************/
 
-static int elp_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t elp_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	unsigned long flags;
 	elp_device *adapter = netdev_priv(dev);
--- a/drivers/net/3c507.c	2009-08-31 16:17:52.521205946 -0700
+++ b/drivers/net/3c507.c	2009-08-31 16:45:35.752869169 -0700
@@ -284,7 +284,8 @@ static unsigned short init_words[] = {
 
 static int	el16_probe1(struct net_device *dev, int ioaddr);
 static int	el16_open(struct net_device *dev);
-static int	el16_send_packet(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t el16_send_packet(struct sk_buff *skb,
+				    struct net_device *dev);
 static irqreturn_t el16_interrupt(int irq, void *dev_id);
 static void el16_rx(struct net_device *dev);
 static int	el16_close(struct net_device *dev);
@@ -509,7 +510,8 @@ static void el16_tx_timeout (struct net_
 }
 
 
-static int el16_send_packet (struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t el16_send_packet (struct sk_buff *skb,
+				     struct net_device *dev)
 {
 	struct net_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
--- a/drivers/net/3c523.c	2009-08-31 16:17:52.521205946 -0700
+++ b/drivers/net/3c523.c	2009-08-31 16:45:15.954461272 -0700
@@ -183,7 +183,7 @@ sizeof(nop_cmd) = 8;
 static irqreturn_t elmc_interrupt(int irq, void *dev_id);
 static int elmc_open(struct net_device *dev);
 static int elmc_close(struct net_device *dev);
-static int elmc_send_packet(struct sk_buff *, struct net_device *);
+static netdev_tx_t elmc_send_packet(struct sk_buff *, struct net_device *);
 static struct net_device_stats *elmc_get_stats(struct net_device *dev);
 static void elmc_timeout(struct net_device *dev);
 #ifdef ELMC_MULTICAST
@@ -1129,7 +1129,7 @@ static void elmc_timeout(struct net_devi
  * send frame
  */
 
-static int elmc_send_packet(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t elmc_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
 	int len;
 	int i;
--- a/drivers/net/3c527.c	2009-08-31 16:17:52.501081183 -0700
+++ b/drivers/net/3c527.c	2009-08-31 16:45:35.002458224 -0700
@@ -213,7 +213,8 @@ static int	mc32_probe1(struct net_device
 static int      mc32_command(struct net_device *dev, u16 cmd, void *data, int len);
 static int	mc32_open(struct net_device *dev);
 static void	mc32_timeout(struct net_device *dev);
-static int	mc32_send_packet(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t mc32_send_packet(struct sk_buff *skb,
+				    struct net_device *dev);
 static irqreturn_t mc32_interrupt(int irq, void *dev_id);
 static int	mc32_close(struct net_device *dev);
 static struct	net_device_stats *mc32_get_stats(struct net_device *dev);
@@ -1020,7 +1021,8 @@ static void mc32_timeout(struct net_devi
  *
  */
 
-static int mc32_send_packet(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t mc32_send_packet(struct sk_buff *skb,
+				    struct net_device *dev)
 {
 	struct mc32_local *lp = netdev_priv(dev);
 	u32 head = atomic_read(&lp->tx_ring_head);
--- a/drivers/net/3c59x.c	2009-08-31 16:17:52.501081183 -0700
+++ b/drivers/net/3c59x.c	2009-08-31 16:45:32.061107786 -0700
@@ -716,8 +716,10 @@ static int mdio_read(struct net_device *
 static void mdio_write(struct net_device *vp, int phy_id, int location, int value);
 static void vortex_timer(unsigned long arg);
 static void rx_oom_timer(unsigned long arg);
-static int vortex_start_xmit(struct sk_buff *skb, struct net_device *dev);
-static int boomerang_start_xmit(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t vortex_start_xmit(struct sk_buff *skb,
+				     struct net_device *dev);
+static netdev_tx_t boomerang_start_xmit(struct sk_buff *skb,
+					struct net_device *dev);
 static int vortex_rx(struct net_device *dev);
 static int boomerang_rx(struct net_device *dev);
 static irqreturn_t vortex_interrupt(int irq, void *dev_id);
@@ -2035,7 +2037,7 @@ vortex_error(struct net_device *dev, int
 	}
 }
 
-static int
+static netdev_tx_t
 vortex_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct vortex_private *vp = netdev_priv(dev);
@@ -2090,7 +2092,7 @@ vortex_start_xmit(struct sk_buff *skb, s
 	return NETDEV_TX_OK;
 }
 
-static int
+static netdev_tx_t
 boomerang_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct vortex_private *vp = netdev_priv(dev);
--- a/drivers/net/3c501.h	2009-08-31 16:17:52.501081183 -0700
+++ b/drivers/net/3c501.h	2009-08-31 16:45:36.451937066 -0700
@@ -6,7 +6,7 @@
 static int  el1_probe1(struct net_device *dev, int ioaddr);
 static int  el_open(struct net_device *dev);
 static void el_timeout(struct net_device *dev);
-static int  el_start_xmit(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t el_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t el_interrupt(int irq, void *dev_id);
 static void el_receive(struct net_device *dev);
 static void el_reset(struct net_device *dev);
--- a/drivers/net/3c509.c	2009-08-31 16:17:52.491216521 -0700
+++ b/drivers/net/3c509.c	2009-08-31 16:45:05.081129325 -0700
@@ -191,7 +191,7 @@ static void el3_common_remove(struct net
 static ushort id_read_eeprom(int index);
 static ushort read_eeprom(int ioaddr, int index);
 static int el3_open(struct net_device *dev);
-static int el3_start_xmit(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t el3_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t el3_interrupt(int irq, void *dev_id);
 static void update_stats(struct net_device *dev);
 static struct net_device_stats *el3_get_stats(struct net_device *dev);
@@ -816,7 +816,7 @@ el3_tx_timeout (struct net_device *dev)
 }
 
 
-static int
+static netdev_tx_t
 el3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct el3_private *lp = netdev_priv(dev);
--- a/drivers/net/3c515.c	2009-08-31 16:17:52.511105850 -0700
+++ b/drivers/net/3c515.c	2009-08-31 16:45:35.411085925 -0700
@@ -369,8 +369,8 @@ static int corkscrew_setup(struct net_de
 			    struct pnp_dev *idev, int card_number);
 static int corkscrew_open(struct net_device *dev);
 static void corkscrew_timer(unsigned long arg);
-static int corkscrew_start_xmit(struct sk_buff *skb,
-				struct net_device *dev);
+static netdev_tx_t corkscrew_start_xmit(struct sk_buff *skb,
+					struct net_device *dev);
 static int corkscrew_rx(struct net_device *dev);
 static void corkscrew_timeout(struct net_device *dev);
 static int boomerang_rx(struct net_device *dev);
@@ -998,8 +998,8 @@ static void corkscrew_timeout(struct net
 	netif_wake_queue(dev);
 }
 
-static int corkscrew_start_xmit(struct sk_buff *skb,
-				struct net_device *dev)
+static netdev_tx_t corkscrew_start_xmit(struct sk_buff *skb,
+					struct net_device *dev)
 {
 	struct corkscrew_private *vp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;

-- 

