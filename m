From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [PATCH net-drivers-2.4] Remove CAP_NET_ADMIN check for SIOCETHTOOL's
Date: Thu, 19 Jun 2003 23:29:16 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0306192326380.6351-100000@localhost.localdomain>
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


diff -Nuarp net-drivers-2.4/drivers/net/acenic.c net-drivers-2.4/drivers/net.mod/acenic.c
--- net-drivers-2.4/drivers/net/acenic.c	2003-03-22 08:07:45.000000000 -0800
+++ net-drivers-2.4/drivers/net.mod/acenic.c	2003-06-19 23:00:08.000000000 -0700
@@ -3017,9 +3017,6 @@ static int ace_ioctl(struct net_device *
 		return 0;
 
 	case ETHTOOL_SSET:
-		if(!capable(CAP_NET_ADMIN))
-			return -EPERM;
-
 		link = readl(&regs->GigLnkState);
 		if (link & LNK_1000MB)
 			speed = SPEED_1000;
diff -Nuarp net-drivers-2.4/drivers/net/e100/e100_main.c net-drivers-2.4/drivers/net.mod/e100/e100_main.c
--- net-drivers-2.4/drivers/net/e100/e100_main.c	2003-06-19 22:12:09.000000000 -0700
+++ net-drivers-2.4/drivers/net.mod/e100/e100_main.c	2003-06-19 23:00:59.000000000 -0700
@@ -3422,10 +3422,6 @@ e100_ethtool_set_settings(struct net_dev
 	int ethtool_new_speed_duplex;
 	struct ethtool_cmd ecmd;
 
-	if (!capable(CAP_NET_ADMIN)) {
-		return -EPERM;
-	}
-
 	bdp = dev->priv;
 	if (copy_from_user(&ecmd, ifr->ifr_data, sizeof (ecmd))) {
 		return -EFAULT;
@@ -3543,8 +3539,6 @@ e100_ethtool_gregs(struct net_device *de
 	void *addr = ifr->ifr_data;
 	u16 mdi_reg;
 
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
 	bdp = dev->priv;
 
 	if(copy_from_user(&regs, addr, sizeof(regs)))
@@ -3572,9 +3566,6 @@ e100_ethtool_nway_rst(struct net_device 
 {
 	struct e100_private *bdp;
 
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
 	bdp = dev->priv;
 
 	if ((bdp->speed_duplex_caps & SUPPORTED_Autoneg) &&
@@ -3630,9 +3621,6 @@ e100_ethtool_eeprom(struct net_device *d
 	void *ptr;
 	u8 *eeprom_data_bytes = (u8 *)eeprom_data;
 
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
 	bdp = dev->priv;
 
 	if (copy_from_user(&ecmd, ifr->ifr_data, sizeof (ecmd)))
@@ -3910,9 +3898,6 @@ e100_ethtool_wol(struct net_device *dev,
 	struct ethtool_wolinfo wolinfo;
 	int res = 0;
 
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
 	bdp = dev->priv;
 
 	if (copy_from_user(&wolinfo, ifr->ifr_data, sizeof (wolinfo))) {
diff -Nuarp net-drivers-2.4/drivers/net/e1000/e1000_ethtool.c net-drivers-2.4/drivers/net.mod/e1000/e1000_ethtool.c
--- net-drivers-2.4/drivers/net/e1000/e1000_ethtool.c	2003-06-19 22:12:09.000000000 -0700
+++ net-drivers-2.4/drivers/net.mod/e1000/e1000_ethtool.c	2003-06-19 23:01:43.000000000 -0700
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
 
diff -Nuarp net-drivers-2.4/drivers/net/ioc3-eth.c net-drivers-2.4/drivers/net.mod/ioc3-eth.c
--- net-drivers-2.4/drivers/net/ioc3-eth.c	2003-03-22 08:07:46.000000000 -0800
+++ net-drivers-2.4/drivers/net.mod/ioc3-eth.c	2003-06-19 23:02:37.000000000 -0700
@@ -1841,9 +1841,6 @@ static int ioc3_ioctl(struct net_device 
 				return -EFAULT;
 			return 0;
 		} else if (ecmd.cmd == ETHTOOL_SSET) {
-			if (!capable(CAP_NET_ADMIN))
-				return -EPERM;
-
 			/* Verify the settings we care about. */
 			if (ecmd.autoneg != AUTONEG_ENABLE &&
 			    ecmd.autoneg != AUTONEG_DISABLE)
diff -Nuarp net-drivers-2.4/drivers/net/sungem.c net-drivers-2.4/drivers/net.mod/sungem.c
--- net-drivers-2.4/drivers/net/sungem.c	2003-03-22 08:07:47.000000000 -0800
+++ net-drivers-2.4/drivers/net.mod/sungem.c	2003-06-19 23:03:16.000000000 -0700
@@ -2616,9 +2616,6 @@ static int gem_ethtool_ioctl(struct net_
 		return 0;
 
 	case ETHTOOL_SSET:
-		if (!capable(CAP_NET_ADMIN))
-			return -EPERM;
-
 		/* Verify the settings we care about. */
 		if (ecmd.autoneg != AUTONEG_ENABLE &&
 		    ecmd.autoneg != AUTONEG_DISABLE)
diff -Nuarp net-drivers-2.4/drivers/net/sunhme.c net-drivers-2.4/drivers/net.mod/sunhme.c
--- net-drivers-2.4/drivers/net/sunhme.c	2003-03-22 08:07:47.000000000 -0800
+++ net-drivers-2.4/drivers/net.mod/sunhme.c	2003-06-19 23:03:36.000000000 -0700
@@ -2480,9 +2480,6 @@ static int happy_meal_ioctl(struct net_d
 			return -EFAULT;
 		return 0;
 	} else if (ecmd.cmd == ETHTOOL_SSET) {
-		if (!capable(CAP_NET_ADMIN))
-			return -EPERM;
-
 		/* Verify the settings we care about. */
 		if (ecmd.autoneg != AUTONEG_ENABLE &&
 		    ecmd.autoneg != AUTONEG_DISABLE)
