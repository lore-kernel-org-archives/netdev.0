From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [PATCH net-drivers-2.5] Remove CAP_NET_ADMIN check for SIOCETHTOOL's
Date: Thu, 19 Jun 2003 23:23:42 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0306192318430.6292-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Feldman, Scott" <scott.feldman@intel.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

dev_ioctl already checks capable(CAP_NET_ADMIN), so no need to do so in 
drivers.


diff -Nuarp net-drivers-2.5/drivers/net/acenic.c net-drivers-2.5/drivers/net.mod/acenic.c
--- net-drivers-2.5/drivers/net/acenic.c	2003-06-19 22:36:55.000000000 -0700
+++ net-drivers-2.5/drivers/net.mod/acenic.c	2003-06-19 22:37:52.000000000 -0700
@@ -3026,9 +3026,6 @@ static int ace_ioctl(struct net_device *
 		return 0;
 
 	case ETHTOOL_SSET:
-		if(!capable(CAP_NET_ADMIN))
-			return -EPERM;
-
 		link = readl(&regs->GigLnkState);
 		if (link & LNK_1000MB)
 			speed = SPEED_1000;
diff -Nuarp net-drivers-2.5/drivers/net/e100/e100_main.c net-drivers-2.5/drivers/net.mod/e100/e100_main.c
--- net-drivers-2.5/drivers/net/e100/e100_main.c	2003-06-19 22:17:58.000000000 -0700
+++ net-drivers-2.5/drivers/net.mod/e100/e100_main.c	2003-06-19 22:43:56.000000000 -0700
@@ -3424,10 +3424,6 @@ e100_ethtool_set_settings(struct net_dev
 	int ethtool_new_speed_duplex;
 	struct ethtool_cmd ecmd;
 
-	if (!capable(CAP_NET_ADMIN)) {
-		return -EPERM;
-	}
-
 	bdp = dev->priv;
 	if (copy_from_user(&ecmd, ifr->ifr_data, sizeof (ecmd))) {
 		return -EFAULT;
@@ -3545,8 +3541,6 @@ e100_ethtool_gregs(struct net_device *de
 	void *addr = ifr->ifr_data;
 	u16 mdi_reg;
 
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
 	bdp = dev->priv;
 
 	if(copy_from_user(&regs, addr, sizeof(regs)))
@@ -3574,9 +3568,6 @@ e100_ethtool_nway_rst(struct net_device 
 {
 	struct e100_private *bdp;
 
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
 	bdp = dev->priv;
 
 	if ((bdp->speed_duplex_caps & SUPPORTED_Autoneg) &&
@@ -3632,9 +3623,6 @@ e100_ethtool_eeprom(struct net_device *d
 	void *ptr;
 	u8 *eeprom_data_bytes = (u8 *)eeprom_data;
 
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
 	bdp = dev->priv;
 
 	if (copy_from_user(&ecmd, ifr->ifr_data, sizeof (ecmd)))
@@ -3912,9 +3900,6 @@ e100_ethtool_wol(struct net_device *dev,
 	struct ethtool_wolinfo wolinfo;
 	int res = 0;
 
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
 	bdp = dev->priv;
 
 	if (copy_from_user(&wolinfo, ifr->ifr_data, sizeof (wolinfo))) {
diff -Nuarp net-drivers-2.5/drivers/net/e1000/e1000_ethtool.c net-drivers-2.5/drivers/net.mod/e1000/e1000_ethtool.c
--- net-drivers-2.5/drivers/net/e1000/e1000_ethtool.c	2003-05-29 17:31:26.000000000 -0700
+++ net-drivers-2.5/drivers/net.mod/e1000/e1000_ethtool.c	2003-06-19 22:45:52.000000000 -0700
@@ -1289,8 +1289,6 @@ e1000_ethtool_ioctl(struct net_device *n
 	}
 	case ETHTOOL_SSET: {
 		struct ethtool_cmd ecmd;
-		if(!capable(CAP_NET_ADMIN))
-			return -EPERM;
 		if(copy_from_user(&ecmd, addr, sizeof(ecmd)))
 			return -EFAULT;
 		return e1000_ethtool_sset(adapter, &ecmd);
@@ -1363,8 +1361,6 @@ e1000_ethtool_ioctl(struct net_device *n
 		return 0;
 	}
 	case ETHTOOL_NWAY_RST: {
-		if(!capable(CAP_NET_ADMIN))
-			return -EPERM;
 		if(netif_running(netdev)) {
 			e1000_down(adapter);
 			e1000_up(adapter);
@@ -1393,8 +1389,6 @@ e1000_ethtool_ioctl(struct net_device *n
 	}
 	case ETHTOOL_SWOL: {
 		struct ethtool_wolinfo wol;
-		if(!capable(CAP_NET_ADMIN))
-			return -EPERM;
 		if(copy_from_user(&wol, addr, sizeof(wol)) != 0)
 			return -EFAULT;
 		return e1000_ethtool_swol(adapter, &wol);
@@ -1436,9 +1430,6 @@ err_geeprom_ioctl:
 	case ETHTOOL_SEEPROM: {
 		struct ethtool_eeprom eeprom;
 
-		if(!capable(CAP_NET_ADMIN))
-			return -EPERM;
-
 		if(copy_from_user(&eeprom, addr, sizeof(eeprom)))
 			return -EFAULT;
 
@@ -1470,9 +1461,6 @@ err_geeprom_ioctl:
 		} test = { {ETHTOOL_TEST} };
 		int err;
 
-		if(!capable(CAP_NET_ADMIN))
-			return -EPERM;
-
 		if(copy_from_user(&test.eth_test, addr, sizeof(test.eth_test)))
 			return -EFAULT;
 
diff -Nuarp net-drivers-2.5/drivers/net/ioc3-eth.c net-drivers-2.5/drivers/net.mod/ioc3-eth.c
--- net-drivers-2.5/drivers/net/ioc3-eth.c	2003-05-29 17:31:26.000000000 -0700
+++ net-drivers-2.5/drivers/net.mod/ioc3-eth.c	2003-06-19 22:49:12.000000000 -0700
@@ -1844,9 +1844,6 @@ static int ioc3_ioctl(struct net_device 
 				return -EFAULT;
 			return 0;
 		} else if (ecmd.cmd == ETHTOOL_SSET) {
-			if (!capable(CAP_NET_ADMIN))
-				return -EPERM;
-
 			/* Verify the settings we care about. */
 			if (ecmd.autoneg != AUTONEG_ENABLE &&
 			    ecmd.autoneg != AUTONEG_DISABLE)
diff -Nuarp net-drivers-2.5/drivers/net/ixgb/ixgb_ethtool.c net-drivers-2.5/drivers/net.mod/ixgb/ixgb_ethtool.c
--- net-drivers-2.5/drivers/net/ixgb/ixgb_ethtool.c	2003-06-19 22:17:58.000000000 -0700
+++ net-drivers-2.5/drivers/net.mod/ixgb/ixgb_ethtool.c	2003-06-19 22:52:06.000000000 -0700
@@ -448,8 +448,6 @@ ixgb_ethtool_ioctl(struct net_device *ne
 	case ETHTOOL_SSET:{
 			struct ethtool_cmd ecmd;
 
-			if (!capable(CAP_NET_ADMIN))
-				return -EPERM;
 			if (copy_from_user(&ecmd, addr, sizeof (ecmd)))
 				return -EFAULT;
 			return ixgb_ethtool_sset(adapter, &ecmd);
@@ -482,9 +480,6 @@ ixgb_ethtool_ioctl(struct net_device *ne
 #endif				/* ETHTOOL_GREGS */
 	case ETHTOOL_NWAY_RST:{
 			IXGB_DBG("ETHTOOL_NWAY_RST\n");
-			if (!capable(CAP_NET_ADMIN))
-				return -EPERM;
-
 			ixgb_down(adapter);
 			ixgb_up(adapter);
 
@@ -539,9 +534,6 @@ ixgb_ethtool_ioctl(struct net_device *ne
 			struct ethtool_eeprom eeprom;
 
 			IXGB_DBG("ETHTOOL_SEEPROM\n");
-			if (!capable(CAP_NET_ADMIN))
-				return -EPERM;
-
 			if (copy_from_user(&eeprom, addr, sizeof (eeprom)))
 				return -EFAULT;
 
diff -Nuarp net-drivers-2.5/drivers/net/sungem.c net-drivers-2.5/drivers/net.mod/sungem.c
--- net-drivers-2.5/drivers/net/sungem.c	2003-06-19 22:17:58.000000000 -0700
+++ net-drivers-2.5/drivers/net.mod/sungem.c	2003-06-19 22:54:01.000000000 -0700
@@ -2384,9 +2384,6 @@ static int gem_ethtool_ioctl(struct net_
 		return 0;
 
 	case ETHTOOL_SSET:
-		if (!capable(CAP_NET_ADMIN))
-			return -EPERM;
-
 		/* Verify the settings we care about. */
 		if (ecmd.autoneg != AUTONEG_ENABLE &&
 		    ecmd.autoneg != AUTONEG_DISABLE)
diff -Nuarp net-drivers-2.5/drivers/net/sunhme.c net-drivers-2.5/drivers/net.mod/sunhme.c
--- net-drivers-2.5/drivers/net/sunhme.c	2003-05-29 17:31:26.000000000 -0700
+++ net-drivers-2.5/drivers/net.mod/sunhme.c	2003-06-19 22:54:47.000000000 -0700
@@ -2481,9 +2481,6 @@ static int happy_meal_ioctl(struct net_d
 			return -EFAULT;
 		return 0;
 	} else if (ecmd.cmd == ETHTOOL_SSET) {
-		if (!capable(CAP_NET_ADMIN))
-			return -EPERM;
-
 		/* Verify the settings we care about. */
 		if (ecmd.autoneg != AUTONEG_ENABLE &&
 		    ecmd.autoneg != AUTONEG_DISABLE)
