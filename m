From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/2] netdev: add missing set_mac_address hook (rev2)
Date: Fri, 9 Jan 2009 13:13:14 -0800
Message-ID: <20090109131314.312d514a@s6510>
References: <20090109124427.71d15306@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42668 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753355AbZAIVNZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 16:13:25 -0500
In-Reply-To: <20090109124427.71d15306@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: netdev: add missing set_mac_address hook

Many drivers lost the ability to set ethernet address accidently
during the net_device_ops conversion.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
(one file was not refreshed properly in last version)

 drivers/net/3c503.c          |    1 +
 drivers/net/8139cp.c         |    2 ++
 drivers/net/8139too.c        |    2 +-
 drivers/net/8390.c           |    1 +
 drivers/net/8390p.c          |    1 +
 drivers/net/arm/etherh.c     |    1 +
 drivers/net/e2100.c          |    1 +
 drivers/net/enic/enic_main.c |    1 +
 drivers/net/hamachi.c        |    1 +
 drivers/net/hp-plus.c        |    1 +
 drivers/net/hydra.c          |    1 +
 drivers/net/mac8390.c        |    1 +
 drivers/net/ne-h8300.c       |    1 +
 drivers/net/ne2k-pci.c       |    1 +
 drivers/net/ns83820.c        |    1 +
 drivers/net/r6040.c          |    1 +
 drivers/net/sc92031.c        |    1 +
 drivers/net/sis900.c         |    1 +
 drivers/net/smc-mca.c        |    1 +
 drivers/net/smc-ultra.c      |    1 +
 drivers/net/smsc911x.c       |    1 +
 drivers/net/smsc9420.c       |    1 +
 drivers/net/via-rhine.c      |    1 +
 drivers/net/via-velocity.c   |    1 +
 drivers/net/wd.c             |    1 +
 drivers/net/yellowfin.c      |    1 +
 drivers/net/zorro8390.c      |    1 +
 27 files changed, 28 insertions(+), 1 deletion(-)

--- a/drivers/net/8139cp.c	2009-01-09 13:00:05.000000000 -0800
+++ b/drivers/net/8139cp.c	2009-01-09 13:00:08.000000000 -0800
@@ -1821,6 +1821,7 @@ static const struct net_device_ops cp_ne
 	.ndo_open		= cp_open,
 	.ndo_stop		= cp_close,
 	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_set_multicast_list	= cp_set_rx_mode,
 	.ndo_get_stats		= cp_get_stats,
 	.ndo_do_ioctl		= cp_ioctl,
@@ -1832,6 +1833,7 @@ static const struct net_device_ops cp_ne
 #ifdef BROKEN
 	.ndo_change_mtu		= cp_change_mtu,
 #endif
+
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= cp_poll_controller,
 #endif
--- a/drivers/net/8139too.c	2009-01-09 13:00:05.000000000 -0800
+++ b/drivers/net/8139too.c	2009-01-09 13:00:08.000000000 -0800
@@ -917,6 +917,7 @@ static const struct net_device_ops rtl81
 	.ndo_stop		= rtl8139_close,
 	.ndo_get_stats		= rtl8139_get_stats,
 	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_start_xmit		= rtl8139_start_xmit,
 	.ndo_set_multicast_list	= rtl8139_set_rx_mode,
 	.ndo_do_ioctl		= netdev_ioctl,
@@ -924,7 +925,6 @@ static const struct net_device_ops rtl81
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= rtl8139_poll_controller,
 #endif
-
 };
 
 static int __devinit rtl8139_init_one (struct pci_dev *pdev,
--- a/drivers/net/3c503.c	2009-01-09 13:00:05.000000000 -0800
+++ b/drivers/net/3c503.c	2009-01-09 13:00:08.000000000 -0800
@@ -177,6 +177,7 @@ static const struct net_device_ops el2_n
 	.ndo_get_stats		= eip_get_stats,
 	.ndo_set_multicast_list = eip_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_change_mtu		= eth_change_mtu,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller 	= eip_poll,
--- a/drivers/net/8390.c	2009-01-09 13:00:05.000000000 -0800
+++ b/drivers/net/8390.c	2009-01-09 13:00:08.000000000 -0800
@@ -63,6 +63,7 @@ const struct net_device_ops ei_netdev_op
 	.ndo_get_stats		= ei_get_stats,
 	.ndo_set_multicast_list = ei_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_change_mtu		= eth_change_mtu,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= ei_poll,
--- a/drivers/net/8390p.c	2009-01-09 13:00:05.000000000 -0800
+++ b/drivers/net/8390p.c	2009-01-09 13:00:08.000000000 -0800
@@ -68,6 +68,7 @@ const struct net_device_ops eip_netdev_o
 	.ndo_get_stats		= eip_get_stats,
 	.ndo_set_multicast_list = eip_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_change_mtu		= eth_change_mtu,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= eip_poll,
--- a/drivers/net/e2100.c	2009-01-09 13:00:05.000000000 -0800
+++ b/drivers/net/e2100.c	2009-01-09 13:00:08.000000000 -0800
@@ -169,6 +169,7 @@ static const struct net_device_ops e21_n
 	.ndo_get_stats		= ei_get_stats,
 	.ndo_set_multicast_list = ei_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_change_mtu		= eth_change_mtu,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller 	= ei_poll,
--- a/drivers/net/hamachi.c	2009-01-09 13:00:05.000000000 -0800
+++ b/drivers/net/hamachi.c	2009-01-09 13:00:08.000000000 -0800
@@ -576,6 +576,7 @@ static const struct net_device_ops hamac
 	.ndo_set_multicast_list	= set_rx_mode,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_tx_timeout		= hamachi_tx_timeout,
 	.ndo_do_ioctl		= netdev_ioctl,
 };
--- a/drivers/net/hp-plus.c	2009-01-09 13:00:05.000000000 -0800
+++ b/drivers/net/hp-plus.c	2009-01-09 13:00:08.000000000 -0800
@@ -166,6 +166,7 @@ static const struct net_device_ops hpp_n
 	.ndo_get_stats		= eip_get_stats,
 	.ndo_set_multicast_list = eip_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_change_mtu		= eth_change_mtu,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= eip_poll,
--- a/drivers/net/hydra.c	2009-01-09 13:00:05.000000000 -0800
+++ b/drivers/net/hydra.c	2009-01-09 13:00:08.000000000 -0800
@@ -103,6 +103,7 @@ static const struct net_device_ops hydra
 	.ndo_get_stats		= ei_get_stats,
 	.ndo_set_multicast_list = ei_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_change_mtu		= eth_change_mtu,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= ei_poll,
--- a/drivers/net/mac8390.c	2009-01-09 13:00:05.000000000 -0800
+++ b/drivers/net/mac8390.c	2009-01-09 13:00:08.000000000 -0800
@@ -486,6 +486,7 @@ static const struct net_device_ops mac83
 	.ndo_get_stats		= ei_get_stats,
 	.ndo_set_multicast_list = ei_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_change_mtu		= eth_change_mtu,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= ei_poll,
--- a/drivers/net/ne-h8300.c	2009-01-09 13:00:05.000000000 -0800
+++ b/drivers/net/ne-h8300.c	2009-01-09 13:00:08.000000000 -0800
@@ -202,6 +202,7 @@ static const struct net_device_ops ne_ne
 	.ndo_get_stats		= ei_get_stats,
 	.ndo_set_multicast_list = ei_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_change_mtu		= eth_change_mtu,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= ei_poll,
--- a/drivers/net/ne2k-pci.c	2009-01-09 13:00:05.000000000 -0800
+++ b/drivers/net/ne2k-pci.c	2009-01-09 13:00:08.000000000 -0800
@@ -208,6 +208,7 @@ static const struct net_device_ops ne2k_
 	.ndo_get_stats		= ei_get_stats,
 	.ndo_set_multicast_list = ei_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_change_mtu		= eth_change_mtu,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = ei_poll,
--- a/drivers/net/ns83820.c	2009-01-09 13:00:05.000000000 -0800
+++ b/drivers/net/ns83820.c	2009-01-09 13:00:08.000000000 -0800
@@ -1956,6 +1956,7 @@ static const struct net_device_ops netde
 	.ndo_change_mtu		= ns83820_change_mtu,
 	.ndo_set_multicast_list = ns83820_set_multicast,
 	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_tx_timeout		= ns83820_tx_timeout,
 #ifdef NS83820_VLAN_ACCEL_SUPPORT
 	.ndo_vlan_rx_register	= ns83820_vlan_rx_register,
--- a/drivers/net/r6040.c	2009-01-09 13:00:05.000000000 -0800
+++ b/drivers/net/r6040.c	2009-01-09 13:00:08.000000000 -0800
@@ -1049,6 +1049,7 @@ static const struct net_device_ops r6040
 	.ndo_set_multicast_list = r6040_multicast_list,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_do_ioctl		= r6040_ioctl,
 	.ndo_tx_timeout		= r6040_tx_timeout,
 #ifdef CONFIG_NET_POLL_CONTROLLER
--- a/drivers/net/sc92031.c	2009-01-09 13:00:05.000000000 -0800
+++ b/drivers/net/sc92031.c	2009-01-09 13:00:08.000000000 -0800
@@ -1408,6 +1408,7 @@ static const struct net_device_ops sc920
 	.ndo_set_multicast_list	= sc92031_set_multicast_list,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_tx_timeout		= sc92031_tx_timeout,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= sc92031_poll_controller,
--- a/drivers/net/sis900.c	2009-01-09 13:00:05.000000000 -0800
+++ b/drivers/net/sis900.c	2009-01-09 13:00:08.000000000 -0800
@@ -389,6 +389,7 @@ static const struct net_device_ops sis90
 	.ndo_set_multicast_list	= set_rx_mode,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_do_ioctl		= mii_ioctl,
 	.ndo_tx_timeout		= sis900_tx_timeout,
 #ifdef CONFIG_NET_POLL_CONTROLLER
--- a/drivers/net/smc-mca.c	2009-01-09 13:00:05.000000000 -0800
+++ b/drivers/net/smc-mca.c	2009-01-09 13:00:08.000000000 -0800
@@ -192,6 +192,7 @@ static const struct net_device_ops ultra
 	.ndo_get_stats		= ei_get_stats,
 	.ndo_set_multicast_list = ei_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_change_mtu		= eth_change_mtu,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller 	= ei_poll,
--- a/drivers/net/smc-ultra.c	2009-01-09 13:00:05.000000000 -0800
+++ b/drivers/net/smc-ultra.c	2009-01-09 13:00:08.000000000 -0800
@@ -196,6 +196,7 @@ static const struct net_device_ops ultra
 	.ndo_get_stats		= ei_get_stats,
 	.ndo_set_multicast_list = ei_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_change_mtu		= eth_change_mtu,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller 	= ei_poll,
--- a/drivers/net/smsc911x.c	2009-01-09 13:00:05.000000000 -0800
+++ b/drivers/net/smsc911x.c	2009-01-09 13:00:08.000000000 -0800
@@ -1740,6 +1740,7 @@ static const struct net_device_ops smsc9
 	.ndo_set_multicast_list	= smsc911x_set_multicast_list,
 	.ndo_do_ioctl		= smsc911x_do_ioctl,
 	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address 	= eth_mac_addr,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= smsc911x_poll_controller,
 #endif
--- a/drivers/net/smsc9420.c	2009-01-09 13:00:05.000000000 -0800
+++ b/drivers/net/smsc9420.c	2009-01-09 13:00:08.000000000 -0800
@@ -1551,6 +1551,7 @@ static const struct net_device_ops smsc9
 	.ndo_set_multicast_list	= smsc9420_set_multicast_list,
 	.ndo_do_ioctl		= smsc9420_do_ioctl,
 	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address 	= eth_mac_addr,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= smsc9420_poll_controller,
 #endif /* CONFIG_NET_POLL_CONTROLLER */
--- a/drivers/net/via-rhine.c	2009-01-09 13:00:05.000000000 -0800
+++ b/drivers/net/via-rhine.c	2009-01-09 13:00:08.000000000 -0800
@@ -622,6 +622,7 @@ static const struct net_device_ops rhine
 	.ndo_get_stats		 = rhine_get_stats,
 	.ndo_set_multicast_list	 = rhine_set_rx_mode,
 	.ndo_validate_addr	 = eth_validate_addr,
+	.ndo_set_mac_address 	 = eth_mac_addr,
 	.ndo_do_ioctl		 = netdev_ioctl,
 	.ndo_tx_timeout 	 = rhine_tx_timeout,
 #ifdef CONFIG_NET_POLL_CONTROLLER
--- a/drivers/net/via-velocity.c	2009-01-09 13:00:05.000000000 -0800
+++ b/drivers/net/via-velocity.c	2009-01-09 13:00:08.000000000 -0800
@@ -855,6 +855,7 @@ static const struct net_device_ops veloc
 	.ndo_start_xmit		= velocity_xmit,
 	.ndo_get_stats		= velocity_get_stats,
 	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_set_multicast_list	= velocity_set_multi,
 	.ndo_change_mtu		= velocity_change_mtu,
 	.ndo_do_ioctl		= velocity_ioctl,
--- a/drivers/net/wd.c	2009-01-09 13:00:05.000000000 -0800
+++ b/drivers/net/wd.c	2009-01-09 13:00:08.000000000 -0800
@@ -155,6 +155,7 @@ static const struct net_device_ops wd_ne
 	.ndo_get_stats		= ei_get_stats,
 	.ndo_set_multicast_list = ei_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_change_mtu		= eth_change_mtu,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller 	= ei_poll,
--- a/drivers/net/yellowfin.c	2009-01-09 13:00:05.000000000 -0800
+++ b/drivers/net/yellowfin.c	2009-01-09 13:00:08.000000000 -0800
@@ -362,6 +362,7 @@ static const struct net_device_ops netde
 	.ndo_set_multicast_list = set_rx_mode,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_do_ioctl 		= netdev_ioctl,
 	.ndo_tx_timeout 	= yellowfin_tx_timeout,
 };
--- a/drivers/net/zorro8390.c	2009-01-09 13:00:05.000000000 -0800
+++ b/drivers/net/zorro8390.c	2009-01-09 13:00:08.000000000 -0800
@@ -147,6 +147,7 @@ static const struct net_device_ops zorro
 	.ndo_get_stats		= ei_get_stats,
 	.ndo_set_multicast_list = ei_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_change_mtu		= eth_change_mtu,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= ei_poll,
--- a/drivers/net/arm/etherh.c	2009-01-09 13:00:05.000000000 -0800
+++ b/drivers/net/arm/etherh.c	2009-01-09 13:00:08.000000000 -0800
@@ -646,6 +646,7 @@ static const struct net_device_ops ether
 	.ndo_get_stats		= ei_get_stats,
 	.ndo_set_multicast_list = ei_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_addr	= eth_set_mac_addr,
 	.ndo_change_mtu		= eth_change_mtu,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= ei_poll,
--- a/drivers/net/enic/enic_main.c	2009-01-09 13:00:05.000000000 -0800
+++ b/drivers/net/enic/enic_main.c	2009-01-09 13:11:10.000000000 -0800
@@ -1599,6 +1599,7 @@ static const struct net_device_ops enic_
 	.ndo_start_xmit		= enic_hard_start_xmit,
 	.ndo_get_stats		= enic_get_stats,
 	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_set_multicast_list	= enic_set_multicast_list,
 	.ndo_change_mtu		= enic_change_mtu,
 	.ndo_vlan_rx_register	= enic_vlan_rx_register,
