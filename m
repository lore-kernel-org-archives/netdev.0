From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net-next 3/6] net: use core MTU range checking in WAN drivers
Date: Tue, 18 Oct 2016 22:33:30 -0400
Message-ID: <20161019023333.15760-4-jarod@redhat.com>
References: <20161019023333.15760-1-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>, netdev@vger.kernel.org,
        Krzysztof Halasa <khc@pm.waw.pl>,
        Krzysztof Halasa <khalasa@piap.pl>,
        Jan Yenya Kasprzak <kas@fi.muni.cz>,
        Francois Romieu <romieu@fr.zoreil.com>,
        Kevin Curtis <kevin.curtis@farsite.co.uk>,
        Zhao Qiang <qiang.zhao@nxp.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161019023333.15760-1-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- set min/max_mtu in all hdlc drivers, remove hdlc_change_mtu
- sent max_mtu in lec driver, remove lec_change_mtu

CC: netdev@vger.kernel.org
CC: Krzysztof Halasa <khc@pm.waw.pl>
CC: Krzysztof Halasa <khalasa@piap.pl>
CC: Jan "Yenya" Kasprzak <kas@fi.muni.cz>
CC: Francois Romieu <romieu@fr.zoreil.com>
CC: Kevin Curtis <kevin.curtis@farsite.co.uk>
CC: Zhao Qiang <qiang.zhao@nxp.com>
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/char/pcmcia/synclink_cs.c |  1 -
 drivers/net/wan/c101.c            |  1 -
 drivers/net/wan/cosa.c            |  1 -
 drivers/net/wan/dscc4.c           |  1 -
 drivers/net/wan/farsync.c         |  1 -
 drivers/net/wan/fsl_ucc_hdlc.c    |  1 -
 drivers/net/wan/hdlc.c            | 11 ++---------
 drivers/net/wan/hdlc_fr.c         |  3 ++-
 drivers/net/wan/hostess_sv11.c    |  1 -
 drivers/net/wan/ixp4xx_hss.c      |  1 -
 drivers/net/wan/lmc/lmc_main.c    |  1 -
 drivers/net/wan/n2.c              |  1 -
 drivers/net/wan/pc300too.c        |  1 -
 drivers/net/wan/pci200syn.c       |  1 -
 drivers/net/wan/sealevel.c        |  1 -
 drivers/net/wan/wanxl.c           |  1 -
 drivers/tty/synclink.c            |  1 -
 drivers/tty/synclink_gt.c         |  1 -
 drivers/tty/synclinkmp.c          |  1 -
 include/linux/hdlc.h              |  2 --
 net/atm/lec.c                     | 11 +----------
 21 files changed, 5 insertions(+), 39 deletions(-)

diff --git a/drivers/char/pcmcia/synclink_cs.c b/drivers/char/pcmcia/synclink_cs.c
index d28922d..a7dd5f4 100644
--- a/drivers/char/pcmcia/synclink_cs.c
+++ b/drivers/char/pcmcia/synclink_cs.c
@@ -4248,7 +4248,6 @@ static void hdlcdev_rx(MGSLPC_INFO *info, char *buf, int size)
 static const struct net_device_ops hdlcdev_ops = {
 	.ndo_open       = hdlcdev_open,
 	.ndo_stop       = hdlcdev_close,
-	.ndo_change_mtu = hdlc_change_mtu,
 	.ndo_start_xmit = hdlc_start_xmit,
 	.ndo_do_ioctl   = hdlcdev_ioctl,
 	.ndo_tx_timeout = hdlcdev_tx_timeout,
diff --git a/drivers/net/wan/c101.c b/drivers/net/wan/c101.c
index 09a5075..2371e07 100644
--- a/drivers/net/wan/c101.c
+++ b/drivers/net/wan/c101.c
@@ -302,7 +302,6 @@ static void c101_destroy_card(card_t *card)
 static const struct net_device_ops c101_ops = {
 	.ndo_open       = c101_open,
 	.ndo_stop       = c101_close,
-	.ndo_change_mtu = hdlc_change_mtu,
 	.ndo_start_xmit = hdlc_start_xmit,
 	.ndo_do_ioctl   = c101_ioctl,
 };
diff --git a/drivers/net/wan/cosa.c b/drivers/net/wan/cosa.c
index b87fe0a..087eb26 100644
--- a/drivers/net/wan/cosa.c
+++ b/drivers/net/wan/cosa.c
@@ -432,7 +432,6 @@ module_exit(cosa_exit);
 static const struct net_device_ops cosa_ops = {
 	.ndo_open       = cosa_net_open,
 	.ndo_stop       = cosa_net_close,
-	.ndo_change_mtu = hdlc_change_mtu,
 	.ndo_start_xmit = hdlc_start_xmit,
 	.ndo_do_ioctl   = cosa_net_ioctl,
 	.ndo_tx_timeout = cosa_net_timeout,
diff --git a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
index 6292259..7351e54 100644
--- a/drivers/net/wan/dscc4.c
+++ b/drivers/net/wan/dscc4.c
@@ -887,7 +887,6 @@ static inline int dscc4_set_quartz(struct dscc4_dev_priv *dpriv, int hz)
 static const struct net_device_ops dscc4_ops = {
 	.ndo_open       = dscc4_open,
 	.ndo_stop       = dscc4_close,
-	.ndo_change_mtu = hdlc_change_mtu,
 	.ndo_start_xmit = hdlc_start_xmit,
 	.ndo_do_ioctl   = dscc4_ioctl,
 	.ndo_tx_timeout = dscc4_tx_timeout,
diff --git a/drivers/net/wan/farsync.c b/drivers/net/wan/farsync.c
index 3c9cbf9..03696d3 100644
--- a/drivers/net/wan/farsync.c
+++ b/drivers/net/wan/farsync.c
@@ -2394,7 +2394,6 @@ fst_init_card(struct fst_card_info *card)
 static const struct net_device_ops fst_ops = {
 	.ndo_open       = fst_open,
 	.ndo_stop       = fst_close,
-	.ndo_change_mtu = hdlc_change_mtu,
 	.ndo_start_xmit = hdlc_start_xmit,
 	.ndo_do_ioctl   = fst_ioctl,
 	.ndo_tx_timeout = fst_tx_timeout,
diff --git a/drivers/net/wan/fsl_ucc_hdlc.c b/drivers/net/wan/fsl_ucc_hdlc.c
index 6564753..e38ce4d 100644
--- a/drivers/net/wan/fsl_ucc_hdlc.c
+++ b/drivers/net/wan/fsl_ucc_hdlc.c
@@ -992,7 +992,6 @@ static const struct dev_pm_ops uhdlc_pm_ops = {
 static const struct net_device_ops uhdlc_ops = {
 	.ndo_open       = uhdlc_open,
 	.ndo_stop       = uhdlc_close,
-	.ndo_change_mtu = hdlc_change_mtu,
 	.ndo_start_xmit = hdlc_start_xmit,
 	.ndo_do_ioctl   = uhdlc_ioctl,
 };
diff --git a/drivers/net/wan/hdlc.c b/drivers/net/wan/hdlc.c
index 9bd4aa8..7221a53 100644
--- a/drivers/net/wan/hdlc.c
+++ b/drivers/net/wan/hdlc.c
@@ -46,14 +46,6 @@ static const char* version = "HDLC support module revision 1.22";
 
 static struct hdlc_proto *first_proto;
 
-int hdlc_change_mtu(struct net_device *dev, int new_mtu)
-{
-	if ((new_mtu < 68) || (new_mtu > HDLC_MAX_MTU))
-		return -EINVAL;
-	dev->mtu = new_mtu;
-	return 0;
-}
-
 static int hdlc_rcv(struct sk_buff *skb, struct net_device *dev,
 		    struct packet_type *p, struct net_device *orig_dev)
 {
@@ -237,6 +229,8 @@ static void hdlc_setup_dev(struct net_device *dev)
 	dev->flags		 = IFF_POINTOPOINT | IFF_NOARP;
 	dev->priv_flags		 = IFF_WAN_HDLC;
 	dev->mtu		 = HDLC_MAX_MTU;
+	dev->min_mtu		 = 68;
+	dev->max_mtu		 = HDLC_MAX_MTU;
 	dev->type		 = ARPHRD_RAWHDLC;
 	dev->hard_header_len	 = 16;
 	dev->addr_len		 = 0;
@@ -353,7 +347,6 @@ MODULE_AUTHOR("Krzysztof Halasa <khc@pm.waw.pl>");
 MODULE_DESCRIPTION("HDLC support module");
 MODULE_LICENSE("GPL v2");
 
-EXPORT_SYMBOL(hdlc_change_mtu);
 EXPORT_SYMBOL(hdlc_start_xmit);
 EXPORT_SYMBOL(hdlc_open);
 EXPORT_SYMBOL(hdlc_close);
diff --git a/drivers/net/wan/hdlc_fr.c b/drivers/net/wan/hdlc_fr.c
index b6e0cfb..eb91528 100644
--- a/drivers/net/wan/hdlc_fr.c
+++ b/drivers/net/wan/hdlc_fr.c
@@ -1053,7 +1053,6 @@ static void pvc_setup(struct net_device *dev)
 static const struct net_device_ops pvc_ops = {
 	.ndo_open       = pvc_open,
 	.ndo_stop       = pvc_close,
-	.ndo_change_mtu = hdlc_change_mtu,
 	.ndo_start_xmit = pvc_xmit,
 	.ndo_do_ioctl   = pvc_ioctl,
 };
@@ -1096,6 +1095,8 @@ static int fr_add_pvc(struct net_device *frad, unsigned int dlci, int type)
 	}
 	dev->netdev_ops = &pvc_ops;
 	dev->mtu = HDLC_MAX_MTU;
+	dev->min_mtu = 68;
+	dev->max_mtu = HDLC_MAX_MTU;
 	dev->priv_flags |= IFF_NO_QUEUE;
 	dev->ml_priv = pvc;
 
diff --git a/drivers/net/wan/hostess_sv11.c b/drivers/net/wan/hostess_sv11.c
index 3d74166..dd6bb33 100644
--- a/drivers/net/wan/hostess_sv11.c
+++ b/drivers/net/wan/hostess_sv11.c
@@ -180,7 +180,6 @@ static int hostess_attach(struct net_device *dev, unsigned short encoding,
 static const struct net_device_ops hostess_ops = {
 	.ndo_open       = hostess_open,
 	.ndo_stop       = hostess_close,
-	.ndo_change_mtu = hdlc_change_mtu,
 	.ndo_start_xmit = hdlc_start_xmit,
 	.ndo_do_ioctl   = hostess_ioctl,
 };
diff --git a/drivers/net/wan/ixp4xx_hss.c b/drivers/net/wan/ixp4xx_hss.c
index e7bbdb7..6a505c2 100644
--- a/drivers/net/wan/ixp4xx_hss.c
+++ b/drivers/net/wan/ixp4xx_hss.c
@@ -1321,7 +1321,6 @@ static int hss_hdlc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 static const struct net_device_ops hss_hdlc_ops = {
 	.ndo_open       = hss_hdlc_open,
 	.ndo_stop       = hss_hdlc_close,
-	.ndo_change_mtu = hdlc_change_mtu,
 	.ndo_start_xmit = hdlc_start_xmit,
 	.ndo_do_ioctl   = hss_hdlc_ioctl,
 };
diff --git a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
index 299140c..001b779 100644
--- a/drivers/net/wan/lmc/lmc_main.c
+++ b/drivers/net/wan/lmc/lmc_main.c
@@ -808,7 +808,6 @@ static int lmc_attach(struct net_device *dev, unsigned short encoding,
 static const struct net_device_ops lmc_ops = {
 	.ndo_open       = lmc_open,
 	.ndo_stop       = lmc_close,
-	.ndo_change_mtu = hdlc_change_mtu,
 	.ndo_start_xmit = hdlc_start_xmit,
 	.ndo_do_ioctl   = lmc_ioctl,
 	.ndo_tx_timeout = lmc_driver_timeout,
diff --git a/drivers/net/wan/n2.c b/drivers/net/wan/n2.c
index 315bf09..c8f4517 100644
--- a/drivers/net/wan/n2.c
+++ b/drivers/net/wan/n2.c
@@ -330,7 +330,6 @@ static void n2_destroy_card(card_t *card)
 static const struct net_device_ops n2_ops = {
 	.ndo_open       = n2_open,
 	.ndo_stop       = n2_close,
-	.ndo_change_mtu = hdlc_change_mtu,
 	.ndo_start_xmit = hdlc_start_xmit,
 	.ndo_do_ioctl   = n2_ioctl,
 };
diff --git a/drivers/net/wan/pc300too.c b/drivers/net/wan/pc300too.c
index db36385..e1dd1ec 100644
--- a/drivers/net/wan/pc300too.c
+++ b/drivers/net/wan/pc300too.c
@@ -291,7 +291,6 @@ static void pc300_pci_remove_one(struct pci_dev *pdev)
 static const struct net_device_ops pc300_ops = {
 	.ndo_open       = pc300_open,
 	.ndo_stop       = pc300_close,
-	.ndo_change_mtu = hdlc_change_mtu,
 	.ndo_start_xmit = hdlc_start_xmit,
 	.ndo_do_ioctl   = pc300_ioctl,
 };
diff --git a/drivers/net/wan/pci200syn.c b/drivers/net/wan/pci200syn.c
index e845562..4e437c5 100644
--- a/drivers/net/wan/pci200syn.c
+++ b/drivers/net/wan/pci200syn.c
@@ -270,7 +270,6 @@ static void pci200_pci_remove_one(struct pci_dev *pdev)
 static const struct net_device_ops pci200_ops = {
 	.ndo_open       = pci200_open,
 	.ndo_stop       = pci200_close,
-	.ndo_change_mtu = hdlc_change_mtu,
 	.ndo_start_xmit = hdlc_start_xmit,
 	.ndo_do_ioctl   = pci200_ioctl,
 };
diff --git a/drivers/net/wan/sealevel.c b/drivers/net/wan/sealevel.c
index 27860b4..fbb5aa2 100644
--- a/drivers/net/wan/sealevel.c
+++ b/drivers/net/wan/sealevel.c
@@ -174,7 +174,6 @@ static int sealevel_attach(struct net_device *dev, unsigned short encoding,
 static const struct net_device_ops sealevel_ops = {
 	.ndo_open       = sealevel_open,
 	.ndo_stop       = sealevel_close,
-	.ndo_change_mtu = hdlc_change_mtu,
 	.ndo_start_xmit = hdlc_start_xmit,
 	.ndo_do_ioctl   = sealevel_ioctl,
 };
diff --git a/drivers/net/wan/wanxl.c b/drivers/net/wan/wanxl.c
index a20d688..0c73175 100644
--- a/drivers/net/wan/wanxl.c
+++ b/drivers/net/wan/wanxl.c
@@ -551,7 +551,6 @@ static void wanxl_pci_remove_one(struct pci_dev *pdev)
 static const struct net_device_ops wanxl_ops = {
 	.ndo_open       = wanxl_open,
 	.ndo_stop       = wanxl_close,
-	.ndo_change_mtu = hdlc_change_mtu,
 	.ndo_start_xmit = hdlc_start_xmit,
 	.ndo_do_ioctl   = wanxl_ioctl,
 	.ndo_get_stats  = wanxl_get_stats,
diff --git a/drivers/tty/synclink.c b/drivers/tty/synclink.c
index c13e27e..415885c 100644
--- a/drivers/tty/synclink.c
+++ b/drivers/tty/synclink.c
@@ -7973,7 +7973,6 @@ static void hdlcdev_rx(struct mgsl_struct *info, char *buf, int size)
 static const struct net_device_ops hdlcdev_ops = {
 	.ndo_open       = hdlcdev_open,
 	.ndo_stop       = hdlcdev_close,
-	.ndo_change_mtu = hdlc_change_mtu,
 	.ndo_start_xmit = hdlc_start_xmit,
 	.ndo_do_ioctl   = hdlcdev_ioctl,
 	.ndo_tx_timeout = hdlcdev_tx_timeout,
diff --git a/drivers/tty/synclink_gt.c b/drivers/tty/synclink_gt.c
index 7aca2d4..8267bcf 100644
--- a/drivers/tty/synclink_gt.c
+++ b/drivers/tty/synclink_gt.c
@@ -1768,7 +1768,6 @@ static void hdlcdev_rx(struct slgt_info *info, char *buf, int size)
 static const struct net_device_ops hdlcdev_ops = {
 	.ndo_open       = hdlcdev_open,
 	.ndo_stop       = hdlcdev_close,
-	.ndo_change_mtu = hdlc_change_mtu,
 	.ndo_start_xmit = hdlc_start_xmit,
 	.ndo_do_ioctl   = hdlcdev_ioctl,
 	.ndo_tx_timeout = hdlcdev_tx_timeout,
diff --git a/drivers/tty/synclinkmp.c b/drivers/tty/synclinkmp.c
index dec1565..d66620f 100644
--- a/drivers/tty/synclinkmp.c
+++ b/drivers/tty/synclinkmp.c
@@ -1887,7 +1887,6 @@ static void hdlcdev_rx(SLMP_INFO *info, char *buf, int size)
 static const struct net_device_ops hdlcdev_ops = {
 	.ndo_open       = hdlcdev_open,
 	.ndo_stop       = hdlcdev_close,
-	.ndo_change_mtu = hdlc_change_mtu,
 	.ndo_start_xmit = hdlc_start_xmit,
 	.ndo_do_ioctl   = hdlcdev_ioctl,
 	.ndo_tx_timeout = hdlcdev_tx_timeout,
diff --git a/include/linux/hdlc.h b/include/linux/hdlc.h
index e31bcd4..97585d9 100644
--- a/include/linux/hdlc.h
+++ b/include/linux/hdlc.h
@@ -93,8 +93,6 @@ static __inline__ void debug_frame(const struct sk_buff *skb)
 int hdlc_open(struct net_device *dev);
 /* Must be called by hardware driver when HDLC device is being closed */
 void hdlc_close(struct net_device *dev);
-/* May be used by hardware driver */
-int hdlc_change_mtu(struct net_device *dev, int new_mtu);
 /* Must be pointed to by hw driver's dev->netdev_ops->ndo_start_xmit */
 netdev_tx_t hdlc_start_xmit(struct sk_buff *skb, struct net_device *dev);
 
diff --git a/net/atm/lec.c b/net/atm/lec.c
index 5d26938..779b3fa 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -544,15 +544,6 @@ send_to_lecd(struct lec_priv *priv, atmlec_msg_type type,
 	return 0;
 }
 
-/* shamelessly stolen from drivers/net/net_init.c */
-static int lec_change_mtu(struct net_device *dev, int new_mtu)
-{
-	if ((new_mtu < 68) || (new_mtu > 18190))
-		return -EINVAL;
-	dev->mtu = new_mtu;
-	return 0;
-}
-
 static void lec_set_multicast_list(struct net_device *dev)
 {
 	/*
@@ -565,7 +556,6 @@ static const struct net_device_ops lec_netdev_ops = {
 	.ndo_open		= lec_open,
 	.ndo_stop		= lec_close,
 	.ndo_start_xmit		= lec_start_xmit,
-	.ndo_change_mtu		= lec_change_mtu,
 	.ndo_tx_timeout		= lec_tx_timeout,
 	.ndo_set_rx_mode	= lec_set_multicast_list,
 };
@@ -742,6 +732,7 @@ static int lecd_attach(struct atm_vcc *vcc, int arg)
 		if (!dev_lec[i])
 			return -ENOMEM;
 		dev_lec[i]->netdev_ops = &lec_netdev_ops;
+		dev_lec[i]->max_mtu = 18190;
 		snprintf(dev_lec[i]->name, IFNAMSIZ, "lec%d", i);
 		if (register_netdev(dev_lec[i])) {
 			free_netdev(dev_lec[i]);
-- 
2.10.0
