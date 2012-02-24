From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 01/12] ethernet: .ndo_set_mac_address: check given address, if invalid return -EADDRNOTAVAIL
Date: Fri, 24 Feb 2012 17:01:11 +0100
Message-ID: <1330099282-4588-2-git-send-email-danny.kukawka@bisect.de>
References: <1330099282-4588-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mips@linux-mips.org
To: Christian Benvenuti <benve@cisco.com>,
        Roopa Prabhu <roprabhu@cisco.com>,
        Neel Patel <neepatel@cisco.com>,
        Nishank Trivedi <nistrive@cisco.com>,
        Guo-Fu Tseng <cooldavid@cooldavid.org>,
        Ralf Baechle <ralf@linux-mips.org>,
        Andy Gospodarek <andy@greyhouse.net>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <1330099282-4588-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

Check if given address is valid in .ndo_set_mac_address, if
invalid return -EADDRNOTAVAIL as eth_mac_addr() already does
if is_valid_ether_addr() fails.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/ethernet/amd/amd8111e.c          |    3 +++
 drivers/net/ethernet/amd/atarilance.c        |    3 +++
 drivers/net/ethernet/chelsio/cxgb/cxgb2.c    |    3 +++
 drivers/net/ethernet/cisco/enic/enic_main.c  |    3 +++
 drivers/net/ethernet/freescale/fec_mpc52xx.c |    3 +++
 drivers/net/ethernet/jme.c                   |    3 +++
 drivers/net/ethernet/micrel/ks8851_mll.c     |    3 +++
 drivers/net/ethernet/micrel/ksz884x.c        |    3 +++
 drivers/net/ethernet/seeq/sgiseeq.c          |    3 +++
 drivers/net/ethernet/sgi/ioc3-eth.c          |    3 +++
 drivers/net/ethernet/tehuti/tehuti.c         |    3 +++
 11 files changed, 33 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/amd/amd8111e.c b/drivers/net/ethernet/amd/amd8111e.c
index 9f62504..b0e3603 100644
--- a/drivers/net/ethernet/amd/amd8111e.c
+++ b/drivers/net/ethernet/amd/amd8111e.c
@@ -1549,6 +1549,9 @@ static int amd8111e_set_mac_address(struct net_device *dev, void *p)
 	int i;
 	struct sockaddr *addr = p;
 
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
 	spin_lock_irq(&lp->lock);
 	/* Setting the MAC address to the device */
diff --git a/drivers/net/ethernet/amd/atarilance.c b/drivers/net/ethernet/amd/atarilance.c
index 70ed79c..a9612f7 100644
--- a/drivers/net/ethernet/amd/atarilance.c
+++ b/drivers/net/ethernet/amd/atarilance.c
@@ -1125,6 +1125,9 @@ static int lance_set_mac_address( struct net_device *dev, void *addr )
 	struct sockaddr *saddr = addr;
 	int i;
 
+	if (!is_valid_ether_addr(saddr->sa_data))
+		return -EADDRNOTAVAIL;
+
 	if (lp->cardtype != OLD_RIEBL && lp->cardtype != NEW_RIEBL)
 		return -EOPNOTSUPP;
 
diff --git a/drivers/net/ethernet/chelsio/cxgb/cxgb2.c b/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
index 1d17c92..8e363ce 100644
--- a/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
+++ b/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
@@ -841,6 +841,9 @@ static int t1_set_mac_addr(struct net_device *dev, void *p)
 	struct cmac *mac = adapter->port[dev->if_port].mac;
 	struct sockaddr *addr = p;
 
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
 	if (!mac->ops->macaddress_set)
 		return -EOPNOTSUPP;
 
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index e27ec1d..67a340d 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -903,6 +903,9 @@ static int enic_set_mac_address(struct net_device *netdev, void *p)
 	struct enic *enic = netdev_priv(netdev);
 	int err;
 
+	if (!is_valid_ether_addr(saddr->sa_data))
+		return -EADDRNOTAVAIL;
+
 	err = enic_dev_del_station_addr(enic);
 	if (err)
 		return err;
diff --git a/drivers/net/ethernet/freescale/fec_mpc52xx.c b/drivers/net/ethernet/freescale/fec_mpc52xx.c
index 7b34d8c..26ea3ad 100644
--- a/drivers/net/ethernet/freescale/fec_mpc52xx.c
+++ b/drivers/net/ethernet/freescale/fec_mpc52xx.c
@@ -123,6 +123,9 @@ static int mpc52xx_fec_set_mac_address(struct net_device *dev, void *addr)
 {
 	struct sockaddr *sock = addr;
 
+	if (!is_valid_ether_addr(sock->sa_data))
+		return -EADDRNOTAVAIL;
+
 	memcpy(dev->dev_addr, sock->sa_data, dev->addr_len);
 
 	mpc52xx_fec_set_paddr(dev, sock->sa_data);
diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
index 1b86d0b..117598e 100644
--- a/drivers/net/ethernet/jme.c
+++ b/drivers/net/ethernet/jme.c
@@ -2271,6 +2271,9 @@ jme_set_macaddr(struct net_device *netdev, void *p)
 	struct jme_adapter *jme = netdev_priv(netdev);
 	struct sockaddr *addr = p;
 
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
 	if (netif_running(netdev))
 		return -EBUSY;
 
diff --git a/drivers/net/ethernet/micrel/ks8851_mll.c b/drivers/net/ethernet/micrel/ks8851_mll.c
index 10d5798..82430ff 100644
--- a/drivers/net/ethernet/micrel/ks8851_mll.c
+++ b/drivers/net/ethernet/micrel/ks8851_mll.c
@@ -1239,6 +1239,9 @@ static int ks_set_mac_address(struct net_device *netdev, void *paddr)
 	struct sockaddr *addr = paddr;
 	u8 *da;
 
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
 	netdev->addr_assign_type &= ~NET_ADDR_RANDOM;
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
 
diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
index ef723b1..db29407 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -5668,6 +5668,9 @@ static int netdev_set_mac_address(struct net_device *dev, void *addr)
 	struct sockaddr *mac = addr;
 	uint interrupt;
 
+	if (!is_valid_ether_addr(mac->sa_data))
+		return -EADDRNOTAVAIL;
+
 	if (priv->port.first_port > 0)
 		hw_del_addr(hw, dev->dev_addr);
 	else {
diff --git a/drivers/net/ethernet/seeq/sgiseeq.c b/drivers/net/ethernet/seeq/sgiseeq.c
index bb8c822..41ad6ba 100644
--- a/drivers/net/ethernet/seeq/sgiseeq.c
+++ b/drivers/net/ethernet/seeq/sgiseeq.c
@@ -163,6 +163,9 @@ static int sgiseeq_set_mac_address(struct net_device *dev, void *addr)
 	struct sgiseeq_private *sp = netdev_priv(dev);
 	struct sockaddr *sa = addr;
 
+	if (!is_valid_ether_addr(sa->sa_data))
+		return -EADDRNOTAVAIL;
+
 	memcpy(dev->dev_addr, sa->sa_data, dev->addr_len);
 
 	spin_lock_irq(&sp->tx_lock);
diff --git a/drivers/net/ethernet/sgi/ioc3-eth.c b/drivers/net/ethernet/sgi/ioc3-eth.c
index ac149d9..a069546 100644
--- a/drivers/net/ethernet/sgi/ioc3-eth.c
+++ b/drivers/net/ethernet/sgi/ioc3-eth.c
@@ -458,6 +458,9 @@ static int ioc3_set_mac_address(struct net_device *dev, void *addr)
 	struct ioc3_private *ip = netdev_priv(dev);
 	struct sockaddr *sa = addr;
 
+	if (!is_valid_ether_addr(sa->sa_data))
+		return -EADDRNOTAVAIL;
+
 	memcpy(dev->dev_addr, sa->sa_data, dev->addr_len);
 
 	spin_lock_irq(&ip->ioc3_lock);
diff --git a/drivers/net/ethernet/tehuti/tehuti.c b/drivers/net/ethernet/tehuti/tehuti.c
index ad973ff..30822ac 100644
--- a/drivers/net/ethernet/tehuti/tehuti.c
+++ b/drivers/net/ethernet/tehuti/tehuti.c
@@ -837,6 +837,9 @@ static int bdx_set_mac(struct net_device *ndev, void *p)
 	struct sockaddr *addr = p;
 
 	ENTER;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
 	/*
 	   if (netif_running(dev))
 	   return -EBUSY
-- 
1.7.8.3
