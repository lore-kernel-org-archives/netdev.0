From: Jeremy Martin <martinjd@csc.uvic.ca>
Subject: [PATCH] fix tuntap oversight
Date: Sun, 11 Apr 2004 23:59:47 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040412065947.GC18810@net-ronin.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: netdev@oss.sgi.com
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

Hi everyone,

This 2.6.5 patch for the universal tuntap driver allows setting the MAC
address via ifconfig(8).  

I'm not subscribed to netdev so if you could CC me that'd be awesome.

-Jeremy

Patch contents:

-- CUT HERE --

===== drivers/net/tun.c 1.33 vs edited =====
--- 1.33/drivers/net/tun.c	Mon Mar 15 12:45:05 2004
+++ edited/drivers/net/tun.c	Sun Apr 11 22:39:06 2004
@@ -117,6 +117,15 @@
 	return &tun->stats;
 }
 
+static int tun_mac_addr(struct net_device *dev, void *p)
+{
+	struct sockaddr *addr=p;
+	if (netif_running(dev))
+		return -EBUSY;
+	memcpy(dev->dev_addr, addr->sa_data,dev->addr_len);
+	return 0;
+}
+
 /* Initialize net device. */
 static void tun_net_init(struct net_device *dev)
 {
@@ -138,6 +147,7 @@
 	case TUN_TAP_DEV:
 		/* Ethernet TAP Device */
 		dev->set_multicast_list = tun_net_mclist;
+		dev->set_mac_address = tun_mac_addr;
 
 		/* Generate random Ethernet address.  */
 		*(u16 *)dev->dev_addr = htons(0x00FF);
