From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: sparc: struct device - replace bus_id with dev_name(),
 dev_set_name()
Date: Thu, 16 Apr 2009 18:21:52 +0200
Message-ID: <1239898912.17211.7.camel@poy>
References: <ac3eb2510811070033m108d8ed5t499c20ee02b2618f@mail.gmail.com>
	 <20081107.013833.147302570.davem@davemloft.net>
	 <ac3eb2510903270521i113df787u7ac5d842ece83740@mail.gmail.com>
	 <20090327.172743.30040617.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: greg@kroah.com, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f169.google.com ([209.85.218.169]:41533 "EHLO
	mail-bw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757162AbZDPQV7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 12:21:59 -0400
In-Reply-To: <20090327.172743.30040617.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-03-27 at 17:27 -0700, David Miller wrote:
> From: Kay Sievers <kay.sievers@vrfy.org>
> Date: Fri, 27 Mar 2009 13:21:56 +0100
> 
> > it took a while, but it happened now, so this issue is coming back. :)
> > 
> > The name size limit is gone, there is no BUS_ID_SIZE thing anymore in
> > the driver core. BUS_ID_SIZE should go away in the 2.6.30 timeframe.
> > 
> > Could you please convert/remove BUS_ID_SIZE value from:
> >   drivers/net/gianfar.h:	char	phy_bus_id[BUS_ID_SIZE];
> >   drivers/net/ucc_geth.h:	char phy_bus_id[BUS_ID_SIZE];
> >   drivers/net/pasemi_mac.h:	char	phy_id[BUS_ID_SIZE];
> >   include/linux/phy.h:#define MII_BUS_ID_SIZE	(BUS_ID_SIZE - 3)
> >   include/linux/phy.h:	char bus_id[BUS_ID_SIZE];
> > 
> > Or let me know how you want to convert it, so I can do it?
> 
> Thanks a lot Kay, I'll look into these cases and take care
> of it.

This moves the 20 into the netdevice header, we need to get rid
of the driver core define now, otherwise people start adding new
code using it, and we want to finish this thankless job finally. :)

Thanks,
Kay


From: Kay Sievers <kay.sievers@vrfy.org>
Subject: net: remove driver-core BUS_ID_SIZE

The name size limit is gone from the driver-core, the BUS_ID_SIZE
value will be removed.

This moves the BUS_ID_SIZE limit to the netdevice as NET_BUS_ID_SIZE.
The limit can probably removed after review and possible adaption of
the netdevice code.

Cc: davem@davemloft.net
Cc: netdev@vger.kernel.org
Acked-by: Greg Kroah-Hartman <gregkh@suse.de>
Signed-off-by: Kay Sievers <kay.sievers@vrfy.org>
---
 drivers/net/arm/ixp4xx_eth.c |    4 ++--
 drivers/net/cpmac.c          |    2 +-
 drivers/net/fec_mpc52xx.c    |    2 +-
 drivers/net/gianfar.h        |    2 +-
 drivers/net/pasemi_mac.h     |    2 +-
 drivers/net/sh_eth.c         |    2 +-
 drivers/net/ucc_geth.h       |    2 +-
 include/linux/netdevice.h    |    3 +++
 include/linux/phy.h          |    5 +++--
 net/core/net-sysfs.c         |    2 +-
 net/wireless/nl80211.c       |    2 +-
 11 files changed, 16 insertions(+), 12 deletions(-)

--- a/drivers/net/arm/ixp4xx_eth.c
+++ b/drivers/net/arm/ixp4xx_eth.c
@@ -1149,7 +1149,7 @@ static int __devinit eth_init_one(struct
 	struct net_device *dev;
 	struct eth_plat_info *plat = pdev->dev.platform_data;
 	u32 regs_phys;
-	char phy_id[BUS_ID_SIZE];
+	char phy_id[NET_BUS_ID_SIZE];
 	int err;
 
 	if (!(dev = alloc_etherdev(sizeof(struct port))))
@@ -1212,7 +1212,7 @@ static int __devinit eth_init_one(struct
 	__raw_writel(DEFAULT_CORE_CNTRL, &port->regs->core_control);
 	udelay(50);
 
-	snprintf(phy_id, BUS_ID_SIZE, PHY_ID_FMT, "0", plat->phy);
+	snprintf(phy_id, NET_BUS_ID_SIZE, PHY_ID_FMT, "0", plat->phy);
 	port->phydev = phy_connect(dev, phy_id, &ixp4xx_adjust_link, 0,
 				   PHY_INTERFACE_MODE_MII);
 	if (IS_ERR(port->phydev)) {
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -202,7 +202,7 @@ struct cpmac_priv {
 	void __iomem *regs;
 	struct mii_bus *mii_bus;
 	struct phy_device *phy;
-	char phy_name[BUS_ID_SIZE];
+	char phy_name[NET_BUS_ID_SIZE];
 	int oldlink, oldspeed, oldduplex;
 	u32 msg_enable;
 	struct net_device *dev;
--- a/drivers/net/fec_mpc52xx.c
+++ b/drivers/net/fec_mpc52xx.c
@@ -215,7 +215,7 @@ static int mpc52xx_fec_init_phy(struct n
 {
 	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
 	struct phy_device *phydev;
-	char phy_id[BUS_ID_SIZE];
+	char phy_id[NET_BUS_ID_SIZE];
 
 	snprintf(phy_id, sizeof(phy_id), "%x:%02x",
 			(unsigned int)dev->base_addr, priv->phy_addr);
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -779,7 +779,7 @@ struct gfar_private {
 	spinlock_t bflock;
 
 	phy_interface_t interface;
-	char	phy_bus_id[BUS_ID_SIZE];
+	char	phy_bus_id[NET_BUS_ID_SIZE];
 	u32 device_flags;
 	unsigned char rx_csum_enable:1,
 		extended_hash:1,
--- a/drivers/net/pasemi_mac.h
+++ b/drivers/net/pasemi_mac.h
@@ -100,7 +100,7 @@ struct pasemi_mac {
 	int	duplex;
 
 	unsigned int	msg_enable;
-	char	phy_id[BUS_ID_SIZE];
+	char	phy_id[NET_BUS_ID_SIZE];
 };
 
 /* Software status descriptor (ring_info) */
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -804,7 +804,7 @@ static void sh_eth_adjust_link(struct ne
 static int sh_eth_phy_init(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
-	char phy_id[BUS_ID_SIZE];
+	char phy_id[NET_BUS_ID_SIZE];
 	struct phy_device *phydev = NULL;
 
 	snprintf(phy_id, sizeof(phy_id), PHY_ID_FMT,
--- a/drivers/net/ucc_geth.h
+++ b/drivers/net/ucc_geth.h
@@ -1100,7 +1100,7 @@ struct ucc_geth_info {
 	u32 eventRegMask;
 	u16 pausePeriod;
 	u16 extensionField;
-	char phy_bus_id[BUS_ID_SIZE];
+	char phy_bus_id[NET_BUS_ID_SIZE];
 	u8 weightfactor[NUM_TX_QUEUES];
 	u8 interruptcoalescingmaxvalue[NUM_RX_QUEUES];
 	u8 l2qt[UCC_GETH_VLAN_PRIORITY_MAX];
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -93,6 +93,9 @@ struct wireless_dev;
 
 #ifdef  __KERNEL__
 
+/* old driver core device name limit */
+#define NET_BUS_ID_SIZE		20
+
 /*
  *	Compute the worst case header length according to the protocols
  *	used.
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -20,6 +20,7 @@
 
 #include <linux/spinlock.h>
 #include <linux/device.h>
+#include <linux/netdevice.h>
 #include <linux/ethtool.h>
 #include <linux/mii.h>
 #include <linux/timer.h>
@@ -79,7 +80,7 @@ typedef enum {
  * Need to be a little smaller than phydev->dev.bus_id to leave room
  * for the ":%02x"
  */
-#define MII_BUS_ID_SIZE	(BUS_ID_SIZE - 3)
+#define MII_BUS_ID_SIZE	(NET_BUS_ID_SIZE - 3)
 
 /*
  * The Bus class for PHYs.  Devices which provide access to
@@ -407,7 +408,7 @@ struct phy_driver {
 /* A Structure for boards to register fixups with the PHY Lib */
 struct phy_fixup {
 	struct list_head list;
-	char bus_id[BUS_ID_SIZE];
+	char bus_id[NET_BUS_ID_SIZE];
 	u32 phy_uid;
 	u32 phy_uid_mask;
 	int (*run)(struct phy_device *phydev);
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -497,7 +497,7 @@ int netdev_register_kobject(struct net_d
 	dev->platform_data = net;
 	dev->groups = groups;
 
-	BUILD_BUG_ON(BUS_ID_SIZE < IFNAMSIZ);
+	BUILD_BUG_ON(NET_BUS_ID_SIZE < IFNAMSIZ);
 	dev_set_name(dev, "%s", net->name);
 
 #ifdef CONFIG_SYSFS
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -57,7 +57,7 @@ static int get_drv_dev_by_info_ifindex(s
 static struct nla_policy nl80211_policy[NL80211_ATTR_MAX+1] __read_mostly = {
 	[NL80211_ATTR_WIPHY] = { .type = NLA_U32 },
 	[NL80211_ATTR_WIPHY_NAME] = { .type = NLA_NUL_STRING,
-				      .len = BUS_ID_SIZE-1 },
+				      .len = NET_BUS_ID_SIZE-1 },
 	[NL80211_ATTR_WIPHY_TXQ_PARAMS] = { .type = NLA_NESTED },
 	[NL80211_ATTR_WIPHY_FREQ] = { .type = NLA_U32 },
 	[NL80211_ATTR_WIPHY_CHANNEL_TYPE] = { .type = NLA_U32 },


