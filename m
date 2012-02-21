From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 1/4] ethernet: unify return value of .ndo_set_mac_address if address is invalid
Date: Tue, 21 Feb 2012 13:07:49 +0100
Message-ID: <1329826072-14689-2-git-send-email-danny.kukawka@bisect.de>
References: <1329826072-14689-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>,
	Kristoffer Glembo <kristoffer@gaisler.com>,
	Michael Chan <mchan@broadcom.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	Divy Le Ray <divy@chelsio.com>,
	Dimitris Michailidis <dm@chelsio.com>,
	Casey Leedom <leedom@chelsio.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Jon Mason <jdmason@kudzu.us>, Olof Johansson <olof@lixom.net>,
	linux-driver@qlogic.com,
	"Solarflare linux maintainers" <linux-net-drivers@solarflare.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Chris Metcalf <cmetcalf@tilera.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329826072-14689-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Unify return value of .ndo_set_mac_address if the given address
isn't valid. Return -EADDRNOTAVAIL as eth_mac_addr() already does
if is_valid_ether_addr() fails.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/ethernet/aeroflex/greth.c              |    2 +-
 drivers/net/ethernet/broadcom/bnx2.c               |    2 +-
 drivers/net/ethernet/broadcom/tg3.c                |    2 +-
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c    |    2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |    2 +-
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |    2 +-
 drivers/net/ethernet/dlink/sundance.c              |    2 +-
 drivers/net/ethernet/marvell/mv643xx_eth.c         |    2 +-
 drivers/net/ethernet/marvell/pxa168_eth.c          |    2 +-
 drivers/net/ethernet/neterion/s2io.c               |    2 +-
 drivers/net/ethernet/pasemi/pasemi_mac.c           |    2 +-
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |    2 +-
 drivers/net/ethernet/sfc/efx.c                     |    2 +-
 drivers/net/ethernet/sun/niu.c                     |    2 +-
 drivers/net/ethernet/ti/davinci_emac.c             |    2 +-
 drivers/net/ethernet/tile/tilepro.c                |    2 +-
 drivers/net/ethernet/tundra/tsi108_eth.c           |    2 +-
 18 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/aeroflex/greth.c b/drivers/net/ethernet/aeroflex/greth.c
index cfa1348..3485011 100644
--- a/drivers/net/ethernet/aeroflex/greth.c
+++ b/drivers/net/ethernet/aeroflex/greth.c
@@ -1017,7 +1017,7 @@ static int greth_set_mac_add(struct net_device *dev, void *p)
 	regs = (struct greth_regs *) greth->regs;
 
 	if (!is_valid_ether_addr(addr->sa_data))
-		return -EINVAL;
+		return -EADDRNOTAVAIL;
 
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
 	GRETH_REGSAVE(regs->esa_msb, dev->dev_addr[0] << 8 | dev->dev_addr[1]);
diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 7105989..8297e28 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -7773,7 +7773,7 @@ bnx2_change_mac_addr(struct net_device *dev, void *p)
 	struct bnx2 *bp = netdev_priv(dev);
 
 	if (!is_valid_ether_addr(addr->sa_data))
-		return -EINVAL;
+		return -EADDRNOTAVAIL;
 
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
 	if (netif_running(dev))
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index d604664..4e0f076 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -8064,7 +8064,7 @@ static int tg3_set_mac_addr(struct net_device *dev, void *p)
 	int err = 0, skip_mac_1 = 0;
 
 	if (!is_valid_ether_addr(addr->sa_data))
-		return -EINVAL;
+		return -EADDRNOTAVAIL;
 
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
 
diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
index 857cc25..63bfdd1 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
@@ -2499,7 +2499,7 @@ static int cxgb_set_mac_addr(struct net_device *dev, void *p)
 	struct sockaddr *addr = p;
 
 	if (!is_valid_ether_addr(addr->sa_data))
-		return -EINVAL;
+		return -EADDRNOTAVAIL;
 
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
 	t3_mac_set_address(&pi->mac, LAN_MAC_IDX, dev->dev_addr);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index e83d12c..1d88942 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -2809,7 +2809,7 @@ static int cxgb_set_mac_addr(struct net_device *dev, void *p)
 	struct port_info *pi = netdev_priv(dev);
 
 	if (!is_valid_ether_addr(addr->sa_data))
-		return -EINVAL;
+		return -EADDRNOTAVAIL;
 
 	ret = t4_change_mac(pi->adapter, pi->adapter->fn, pi->viid,
 			    pi->xact_addr_filt, addr->sa_data, true, true);
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 9045a45..3f580c0 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -1130,7 +1130,7 @@ static int cxgb4vf_set_mac_addr(struct net_device *dev, void *_addr)
 	struct port_info *pi = netdev_priv(dev);
 
 	if (!is_valid_ether_addr(addr->sa_data))
-		return -EINVAL;
+		return -EADDRNOTAVAIL;
 
 	ret = t4vf_change_mac(pi->adapter, pi->viid, pi->xact_addr_filt,
 			      addr->sa_data, true);
diff --git a/drivers/net/ethernet/dlink/sundance.c b/drivers/net/ethernet/dlink/sundance.c
index 7227f29..d783f4f 100644
--- a/drivers/net/ethernet/dlink/sundance.c
+++ b/drivers/net/ethernet/dlink/sundance.c
@@ -1601,7 +1601,7 @@ static int sundance_set_mac_addr(struct net_device *dev, void *data)
 	const struct sockaddr *addr = data;
 
 	if (!is_valid_ether_addr(addr->sa_data))
-		return -EINVAL;
+		return -EADDRNOTAVAIL;
 	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
 	__set_mac_addr(dev);
 
diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index f702d0d..75af1af 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -1832,7 +1832,7 @@ static int mv643xx_eth_set_mac_address(struct net_device *dev, void *addr)
 	struct sockaddr *sa = addr;
 
 	if (!is_valid_ether_addr(sa->sa_data))
-		return -EINVAL;
+		return -EADDRNOTAVAIL;
 
 	memcpy(dev->dev_addr, sa->sa_data, ETH_ALEN);
 
diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index 83e37ad..3a7df05 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -627,7 +627,7 @@ static int pxa168_eth_set_mac_address(struct net_device *dev, void *addr)
 	unsigned char oldMac[ETH_ALEN];
 
 	if (!is_valid_ether_addr(sa->sa_data))
-		return -EINVAL;
+		return -EADDRNOTAVAIL;
 	memcpy(oldMac, dev->dev_addr, ETH_ALEN);
 	dev->addr_assign_type &= ~NET_ADDR_RANDOM;
 	memcpy(dev->dev_addr, sa->sa_data, ETH_ALEN);
diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index 44a6065..22a8de0 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -5248,7 +5248,7 @@ static int s2io_set_mac_addr(struct net_device *dev, void *p)
 	struct sockaddr *addr = p;
 
 	if (!is_valid_ether_addr(addr->sa_data))
-		return -EINVAL;
+		return -EADDRNOTAVAIL;
 
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
 
diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.c b/drivers/net/ethernet/pasemi/pasemi_mac.c
index 667498e..ddc95b0 100644
--- a/drivers/net/ethernet/pasemi/pasemi_mac.c
+++ b/drivers/net/ethernet/pasemi/pasemi_mac.c
@@ -238,7 +238,7 @@ static int pasemi_mac_set_mac_addr(struct net_device *dev, void *p)
 	unsigned int adr0, adr1;
 
 	if (!is_valid_ether_addr(addr->sa_data))
-		return -EINVAL;
+		return -EADDRNOTAVAIL;
 
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
 
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index 8dc4a134..7648995 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -518,7 +518,7 @@ static int netxen_nic_set_mac(struct net_device *netdev, void *p)
 	struct sockaddr *addr = p;
 
 	if (!is_valid_ether_addr(addr->sa_data))
-		return -EINVAL;
+		return -EADDRNOTAVAIL;
 
 	if (netif_running(netdev)) {
 		netif_device_detach(netdev);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index dba9531..81bb1a6 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -301,7 +301,7 @@ static int qlcnic_set_mac(struct net_device *netdev, void *p)
 		return -EOPNOTSUPP;
 
 	if (!is_valid_ether_addr(addr->sa_data))
-		return -EINVAL;
+		return -EADDRNOTAVAIL;
 
 	if (test_bit(__QLCNIC_DEV_UP, &adapter->state)) {
 		netif_device_detach(netdev);
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index ac571cf..d50b03f 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1930,7 +1930,7 @@ static int efx_set_mac_address(struct net_device *net_dev, void *data)
 		netif_err(efx, drv, efx->net_dev,
 			  "invalid ethernet MAC address requested: %pM\n",
 			  new_addr);
-		return -EINVAL;
+		return -EADDRNOTAVAIL;
 	}
 
 	memcpy(net_dev->dev_addr, new_addr, net_dev->addr_len);
diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index d83c508..c99b3b0 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -6412,7 +6412,7 @@ static int niu_set_mac_addr(struct net_device *dev, void *p)
 	unsigned long flags;
 
 	if (!is_valid_ether_addr(addr->sa_data))
-		return -EINVAL;
+		return -EADDRNOTAVAIL;
 
 	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
 
diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index f053aeb..6d74cb7 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -1254,7 +1254,7 @@ static int emac_dev_setmac_addr(struct net_device *ndev, void *addr)
 	struct sockaddr *sa = addr;
 
 	if (!is_valid_ether_addr(sa->sa_data))
-		return -EINVAL;
+		return -EADDRNOTAVAIL;
 
 	/* Store mac addr in priv and rx channel and set it in EMAC hw */
 	memcpy(priv->mac_addr, sa->sa_data, ndev->addr_len);
diff --git a/drivers/net/ethernet/tile/tilepro.c b/drivers/net/ethernet/tile/tilepro.c
index 948c4f2..261356c 100644
--- a/drivers/net/ethernet/tile/tilepro.c
+++ b/drivers/net/ethernet/tile/tilepro.c
@@ -2186,7 +2186,7 @@ static int tile_net_set_mac_address(struct net_device *dev, void *p)
 	struct sockaddr *addr = p;
 
 	if (!is_valid_ether_addr(addr->sa_data))
-		return -EINVAL;
+		return -EADDRNOTAVAIL;
 
 	/* ISSUE: Note that "dev_addr" is now a pointer. */
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
diff --git a/drivers/net/ethernet/tundra/tsi108_eth.c b/drivers/net/ethernet/tundra/tsi108_eth.c
index fc5521c..840e0e9 100644
--- a/drivers/net/ethernet/tundra/tsi108_eth.c
+++ b/drivers/net/ethernet/tundra/tsi108_eth.c
@@ -1148,7 +1148,7 @@ static int tsi108_set_mac(struct net_device *dev, void *addr)
 	int i;
 
 	if (!is_valid_ether_addr(addr))
-		return -EINVAL;
+		return -EADDRNOTAVAIL;
 
 	for (i = 0; i < 6; i++)
 		/* +2 is for the offset of the HW addr type */
-- 
1.7.8.3
