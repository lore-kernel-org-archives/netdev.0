From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: [PATCH net-next 1/2] net: break include loop netdevice.h, dsa.h, devlink.h
Date: Tue, 28 Mar 2017 23:45:06 +0200
Message-ID: <1490737507-7864-2-git-send-email-andrew@lunn.ch>
References: <1490737507-7864-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, sfrench-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org,
        linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Vivien Didelot <vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-cifs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1490737507-7864-1-git-send-email-andrew-g2DYL2Zd6BY@public.gmane.org>
Sender: linux-cifs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

There is an include loop between netdevice.h, dsa.h, devlink.h because
of NETDEV_ALIGN, making it impossible to use devlink structures in
dsa.h.

Break this loop by taking dsa.h out of netdevice.h, add a forward
declaration of dsa_switch_tree and netdev_set_default_ethtool_ops()
function, which is what netdevice.h requires.

No longer having dsa.h in netdevice.h means the includes in dsa.h no
longer get included. This breaks a few other files which depend on
these includes. Add these directly in the affected file.

Signed-off-by: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
---
 drivers/net/dsa/bcm_sf2_cfp.c                    |  3 ++-
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h            |  1 +
 drivers/net/ethernet/broadcom/bcmsysport.c       |  1 +
 drivers/net/ethernet/freescale/fman/fman_memac.h |  1 +
 drivers/net/ethernet/hisilicon/hns/hnae.c        |  2 +-
 drivers/net/ieee802154/mrf24j40.c                |  1 +
 drivers/net/phy/smsc.c                           |  1 +
 drivers/net/usb/lan78xx.c                        |  1 +
 fs/cifs/cifsfs.c                                 |  1 +
 fs/cifs/connect.c                                |  1 +
 fs/cifs/smb2pdu.c                                |  1 +
 include/linux/netdevice.h                        | 12 ++----------
 include/net/dsa.h                                |  9 +++++++++
 net/bridge/br_if.c                               |  1 +
 net/core/netprio_cgroup.c                        |  1 +
 net/dsa/dsa.c                                    |  3 ++-
 net/dsa/dsa2.c                                   |  3 ++-
 net/dsa/slave.c                                  |  1 +
 net/dsa/tag_brcm.c                               |  1 +
 net/dsa/tag_dsa.c                                |  1 +
 net/dsa/tag_edsa.c                               |  1 +
 net/dsa/tag_qca.c                                |  1 +
 net/dsa/tag_trailer.c                            |  1 +
 net/ipv4/ipconfig.c                              |  1 +
 24 files changed, 36 insertions(+), 14 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2_cfp.c b/drivers/net/dsa/bcm_sf2_cfp.c
index 346dd9a1232d..2fb32d67065f 100644
--- a/drivers/net/dsa/bcm_sf2_cfp.c
+++ b/drivers/net/dsa/bcm_sf2_cfp.c
@@ -10,10 +10,11 @@
  */
 
 #include <linux/list.h>
-#include <net/dsa.h>
 #include <linux/ethtool.h>
 #include <linux/if_ether.h>
 #include <linux/in.h>
+#include <linux/netdevice.h>
+#include <net/dsa.h>
 #include <linux/bitmap.h>
 
 #include "bcm_sf2.h"
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 75be2c339a49..55367d05374e 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -16,6 +16,7 @@
 #include <linux/irq.h>
 #include <linux/gpio/consumer.h>
 #include <linux/phy.h>
+#include <net/dsa.h>
 
 #ifndef UINT64_MAX
 #define UINT64_MAX		(u64)(~((u64)0))
diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 61e26c6b26ab..099b374c1b17 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -22,6 +22,7 @@
 #include <linux/of_mdio.h>
 #include <linux/phy.h>
 #include <linux/phy_fixed.h>
+#include <net/dsa.h>
 #include <net/ip.h>
 #include <net/ipv6.h>
 
diff --git a/drivers/net/ethernet/freescale/fman/fman_memac.h b/drivers/net/ethernet/freescale/fman/fman_memac.h
index 173d8e0fd716..c4a66469a907 100644
--- a/drivers/net/ethernet/freescale/fman/fman_memac.h
+++ b/drivers/net/ethernet/freescale/fman/fman_memac.h
@@ -36,6 +36,7 @@
 #include "fman_mac.h"
 
 #include <linux/netdevice.h>
+#include <linux/phy_fixed.h>
 
 struct fman_mac *memac_config(struct fman_mac_params *params);
 int memac_set_promiscuous(struct fman_mac *memac, bool new_val);
diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.c b/drivers/net/ethernet/hisilicon/hns/hnae.c
index b6ed818f78ff..120427a40883 100644
--- a/drivers/net/ethernet/hisilicon/hns/hnae.c
+++ b/drivers/net/ethernet/hisilicon/hns/hnae.c
@@ -9,9 +9,9 @@
 
 #include <linux/dma-mapping.h>
 #include <linux/interrupt.h>
+#include <linux/of.h>
 #include <linux/skbuff.h>
 #include <linux/slab.h>
-
 #include "hnae.h"
 
 #define cls_to_ae_dev(dev) container_of(dev, struct hnae_ae_dev, cls_dev)
diff --git a/drivers/net/ieee802154/mrf24j40.c b/drivers/net/ieee802154/mrf24j40.c
index 7b131f8e4093..bd63289c55e8 100644
--- a/drivers/net/ieee802154/mrf24j40.c
+++ b/drivers/net/ieee802154/mrf24j40.c
@@ -18,6 +18,7 @@
 #include <linux/spi/spi.h>
 #include <linux/interrupt.h>
 #include <linux/module.h>
+#include <linux/of.h>
 #include <linux/regmap.h>
 #include <linux/ieee802154.h>
 #include <linux/irq.h>
diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
index fb32eaf2255d..cef6967b0396 100644
--- a/drivers/net/phy/smsc.c
+++ b/drivers/net/phy/smsc.c
@@ -20,6 +20,7 @@
 #include <linux/module.h>
 #include <linux/mii.h>
 #include <linux/ethtool.h>
+#include <linux/of.h>
 #include <linux/phy.h>
 #include <linux/netdevice.h>
 #include <linux/smscphy.h>
diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index d885e0325422..a17e32bf5f92 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -29,6 +29,7 @@
 #include <linux/ip.h>
 #include <linux/ipv6.h>
 #include <linux/mdio.h>
+#include <linux/phy.h>
 #include <net/ip6_checksum.h>
 #include <linux/interrupt.h>
 #include <linux/irqdomain.h>
diff --git a/fs/cifs/cifsfs.c b/fs/cifs/cifsfs.c
index 15e1db8738ae..8c91f37ac0eb 100644
--- a/fs/cifs/cifsfs.c
+++ b/fs/cifs/cifsfs.c
@@ -37,6 +37,7 @@
 #include <linux/freezer.h>
 #include <linux/namei.h>
 #include <linux/random.h>
+#include <linux/uuid.h>
 #include <linux/xattr.h>
 #include <net/ipv6.h>
 #include "cifsfs.h"
diff --git a/fs/cifs/connect.c b/fs/cifs/connect.c
index 9ae695ae3ed7..858698dcde3c 100644
--- a/fs/cifs/connect.c
+++ b/fs/cifs/connect.c
@@ -35,6 +35,7 @@
 #include <linux/pagevec.h>
 #include <linux/freezer.h>
 #include <linux/namei.h>
+#include <linux/uuid.h>
 #include <linux/uaccess.h>
 #include <asm/processor.h>
 #include <linux/inet.h>
diff --git a/fs/cifs/smb2pdu.c b/fs/cifs/smb2pdu.c
index 7446496850a3..fb75fe908225 100644
--- a/fs/cifs/smb2pdu.c
+++ b/fs/cifs/smb2pdu.c
@@ -33,6 +33,7 @@
 #include <linux/vfs.h>
 #include <linux/task_io_accounting_ops.h>
 #include <linux/uaccess.h>
+#include <linux/uuid.h>
 #include <linux/pagemap.h>
 #include <linux/xattr.h>
 #include "smb2pdu.h"
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b7365b587818..cc07c3be2705 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -41,7 +41,6 @@
 
 #include <linux/ethtool.h>
 #include <net/net_namespace.h>
-#include <net/dsa.h>
 #ifdef CONFIG_DCB
 #include <net/dcbnl.h>
 #endif
@@ -57,6 +56,8 @@
 struct netpoll_info;
 struct device;
 struct phy_device;
+struct dsa_switch_tree;
+
 /* 802.11 specific */
 struct wireless_dev;
 /* 802.15.4 specific */
@@ -2004,15 +2005,6 @@ void dev_net_set(struct net_device *dev, struct net *net)
 	write_pnet(&dev->nd_net, net);
 }
 
-static inline bool netdev_uses_dsa(struct net_device *dev)
-{
-#if IS_ENABLED(CONFIG_NET_DSA)
-	if (dev->dsa_ptr != NULL)
-		return dsa_uses_tagged_protocol(dev->dsa_ptr);
-#endif
-	return false;
-}
-
 /**
  *	netdev_priv - access network device private data
  *	@dev: network device
diff --git a/include/net/dsa.h b/include/net/dsa.h
index e42897fd7a96..f80e81912b83 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -468,6 +468,15 @@ static inline bool dsa_uses_tagged_protocol(struct dsa_switch_tree *dst)
 	return dst->rcv != NULL;
 }
 
+static inline bool netdev_uses_dsa(struct net_device *dev)
+{
+#if IS_ENABLED(CONFIG_NET_DSA)
+	if (dev->dsa_ptr != NULL)
+		return dsa_uses_tagged_protocol(dev->dsa_ptr);
+#endif
+	return false;
+}
+
 struct dsa_switch *dsa_switch_alloc(struct device *dev, size_t n);
 void dsa_unregister_switch(struct dsa_switch *ds);
 int dsa_register_switch(struct dsa_switch *ds, struct device *dev);
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 8ac1770aa222..6eb52d422dd9 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -22,6 +22,7 @@
 #include <linux/rtnetlink.h>
 #include <linux/if_ether.h>
 #include <linux/slab.h>
+#include <net/dsa.h>
 #include <net/sock.h>
 #include <linux/if_vlan.h>
 #include <net/switchdev.h>
diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index 0f9275ee5595..1c4810919a0a 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -11,6 +11,7 @@
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
+#include <linux/module.h>
 #include <linux/slab.h>
 #include <linux/types.h>
 #include <linux/module.h>
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index b6d4f6a23f06..95d1a756202c 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -14,15 +14,16 @@
 #include <linux/platform_device.h>
 #include <linux/slab.h>
 #include <linux/module.h>
-#include <net/dsa.h>
 #include <linux/of.h>
 #include <linux/of_mdio.h>
 #include <linux/of_platform.h>
 #include <linux/of_net.h>
 #include <linux/of_gpio.h>
+#include <linux/netdevice.h>
 #include <linux/sysfs.h>
 #include <linux/phy_fixed.h>
 #include <linux/gpio/consumer.h>
+#include <net/dsa.h>
 #include "dsa_priv.h"
 
 static struct sk_buff *dsa_slave_notag_xmit(struct sk_buff *skb,
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 737be6470c7f..d039c8d7adfd 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -13,11 +13,12 @@
 #include <linux/device.h>
 #include <linux/err.h>
 #include <linux/list.h>
+#include <linux/netdevice.h>
 #include <linux/slab.h>
 #include <linux/rtnetlink.h>
-#include <net/dsa.h>
 #include <linux/of.h>
 #include <linux/of_net.h>
+#include <net/dsa.h>
 #include "dsa_priv.h"
 
 static LIST_HEAD(dsa_switch_trees);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 78128acfbf63..7693182df81e 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -17,6 +17,7 @@
 #include <linux/of_mdio.h>
 #include <linux/mdio.h>
 #include <linux/list.h>
+#include <net/dsa.h>
 #include <net/rtnetlink.h>
 #include <net/switchdev.h>
 #include <net/pkt_cls.h>
diff --git a/net/dsa/tag_brcm.c b/net/dsa/tag_brcm.c
index 5d925b6b2bb1..e2ed6cf68261 100644
--- a/net/dsa/tag_brcm.c
+++ b/net/dsa/tag_brcm.c
@@ -12,6 +12,7 @@
 #include <linux/etherdevice.h>
 #include <linux/list.h>
 #include <linux/slab.h>
+#include <net/dsa.h>
 #include "dsa_priv.h"
 
 /* This tag length is 4 bytes, older ones were 6 bytes, we do not
diff --git a/net/dsa/tag_dsa.c b/net/dsa/tag_dsa.c
index 72579ceea381..e42ba906100c 100644
--- a/net/dsa/tag_dsa.c
+++ b/net/dsa/tag_dsa.c
@@ -11,6 +11,7 @@
 #include <linux/etherdevice.h>
 #include <linux/list.h>
 #include <linux/slab.h>
+#include <net/dsa.h>
 #include "dsa_priv.h"
 
 #define DSA_HLEN	4
diff --git a/net/dsa/tag_edsa.c b/net/dsa/tag_edsa.c
index 648c051817a1..6a9b7a9e4e15 100644
--- a/net/dsa/tag_edsa.c
+++ b/net/dsa/tag_edsa.c
@@ -11,6 +11,7 @@
 #include <linux/etherdevice.h>
 #include <linux/list.h>
 #include <linux/slab.h>
+#include <net/dsa.h>
 #include "dsa_priv.h"
 
 #define DSA_HLEN	4
diff --git a/net/dsa/tag_qca.c b/net/dsa/tag_qca.c
index 30240f343aea..4e0dad759d04 100644
--- a/net/dsa/tag_qca.c
+++ b/net/dsa/tag_qca.c
@@ -12,6 +12,7 @@
  */
 
 #include <linux/etherdevice.h>
+#include <net/dsa.h>
 #include "dsa_priv.h"
 
 #define QCA_HDR_LEN	2
diff --git a/net/dsa/tag_trailer.c b/net/dsa/tag_trailer.c
index 26f977176978..74c948512550 100644
--- a/net/dsa/tag_trailer.c
+++ b/net/dsa/tag_trailer.c
@@ -11,6 +11,7 @@
 #include <linux/etherdevice.h>
 #include <linux/list.h>
 #include <linux/slab.h>
+#include <net/dsa.h>
 #include "dsa_priv.h"
 
 static struct sk_buff *trailer_xmit(struct sk_buff *skb, struct net_device *dev)
diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index fd9f34bbd740..9def8ed31c76 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -57,6 +57,7 @@
 #include <linux/export.h>
 #include <net/net_namespace.h>
 #include <net/arp.h>
+#include <net/dsa.h>
 #include <net/ip.h>
 #include <net/ipconfig.h>
 #include <net/route.h>
-- 
2.11.0
