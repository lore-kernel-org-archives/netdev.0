From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] xtensa platform-iss network: remove no-op ioctl handler
Date: Mon, 7 Nov 2005 06:20:36 +0100
Message-ID: <20051107052036.GB17808@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, chris@zankel.net
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

If the driver ever wants to add ethtool support it should use
ethtool_ops.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/arch/xtensa/platform-iss/network.c
===================================================================
--- linux-2.6.orig/arch/xtensa/platform-iss/network.c	2005-10-31 13:15:49.000000000 +0100
+++ linux-2.6/arch/xtensa/platform-iss/network.c	2005-11-04 15:17:16.000000000 +0100
@@ -611,38 +611,6 @@
 	return -EINVAL;
 }
 
-static int iss_net_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
-{
-#if 0
-	static const struct ethtool_drvinfo info = {
-		.cmd     = ETHTOOL_GDRVINFO,
-		.driver  = DRIVER_NAME,
-		.version = "42",
-	};
-	void *useraddr;
-	u32 ethcmd;
-
-	switch (cmd) {
-	case SIOCETHTOOL:
-		useraddr = ifr->ifr_data;
-		if (copy_from_user(&ethcmd, useraddr, sizeof(ethcmd)))
-			return -EFAULT;
-
-		switch (ethcmd) {
-			case ETHTOOL_GDRVINFO:
-				if (copy_to_user(useraddr, &info, sizeof(info)))
-					return -EFAULT;
-				return 0;
-			default:
-				return -EOPNOTSUPP;
-		}
-	default:
-		return -EINVAL;
-	}
-#endif
-	return -EINVAL;
-}
-
 void iss_net_user_timer_expire(unsigned long _conn)
 {
 }
@@ -730,7 +698,6 @@
 	dev->tx_timeout = iss_net_tx_timeout;
 	dev->set_mac_address = iss_net_set_mac;
 	dev->change_mtu = iss_net_change_mtu;
-	dev->do_ioctl = iss_net_ioctl;
 	dev->watchdog_timeo = (HZ >> 1);
 	dev->irq = -1;
 
