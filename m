From: "Steven J. Magnani" <steve@digidescorp.com>
Subject: [PATCH] ll_temac: Fix MAC address configuration from userland
Date: Wed, 17 Feb 2010 11:55:07 -0600
Message-ID: <1266429307-11765-1-git-send-email-steve@digidescorp.com>
Cc: linux-kernel@vger.kernel.org,
	"Steven J. Magnani" <steve@digidescorp.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A userland command to set the LLTEMAC MAC address,
i.e. "ifconfig eth0 hw addr xx:yy:zz:pp:dd:qq",
results in a device address of 00:01:xx:yy:zz:pp.
Correct this.

Signed-off-by: Steven J. Magnani <steve@digidescorp.com>
---
diff -uprN a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_main.c
--- a/drivers/net/ll_temac_main.c	2010-02-17 10:38:35.000000000 -0600
+++ b/drivers/net/ll_temac_main.c	2010-02-17 11:47:45.000000000 -0600
@@ -224,6 +224,13 @@ static int temac_set_mac_address(struct 
 	return 0;
 }
 
+static int netdev_set_mac_address(struct net_device *ndev, void *p)
+{
+	struct sockaddr *addr = p;
+
+	return temac_set_mac_address(ndev, addr->sa_data);
+}
+
 static void temac_set_multicast_list(struct net_device *ndev)
 {
 	struct temac_local *lp = netdev_priv(ndev);
@@ -768,7 +775,7 @@ static const struct net_device_ops temac
 	.ndo_open = temac_open,
 	.ndo_stop = temac_stop,
 	.ndo_start_xmit = temac_start_xmit,
-	.ndo_set_mac_address = temac_set_mac_address,
+	.ndo_set_mac_address = netdev_set_mac_address,
 	//.ndo_set_multicast_list = temac_set_multicast_list,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = temac_poll_controller,
