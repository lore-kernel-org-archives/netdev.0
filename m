From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] NETDEV: fix receiving multicast frames.
Date: Wed, 25 May 2005 16:07:04 +0900 (JST)
Message-ID: <20050525.160704.28910448.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org, usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Some USB ethernet drivers did not accept multicast frames appropriately.
IPv6 did not work with those drivers without this patch.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Index: drivers/usb/net/pegasus.c
===================================================================
--- 5b713315560487f8c288820b17061fe27016c2cc/drivers/usb/net/pegasus.c  (mode:100644)
+++ uncommitted/drivers/usb/net/pegasus.c  (mode:100644)
@@ -1166,7 +1166,7 @@
 		pegasus->eth_regs[EthCtrl2] |= RX_PROMISCUOUS;
 		if (netif_msg_link(pegasus))
 			pr_info("%s: Promiscuous mode enabled.\n", net->name);
-	} else if ((net->mc_count > multicast_filter_limit) ||
+	} else if (net->mc_count ||
 		   (net->flags & IFF_ALLMULTI)) {
 		pegasus->eth_regs[EthCtrl0] |= RX_MULTICAST;
 		pegasus->eth_regs[EthCtrl2] &= ~RX_PROMISCUOUS;
Index: drivers/usb/net/rtl8150.c
===================================================================
--- 5b713315560487f8c288820b17061fe27016c2cc/drivers/usb/net/rtl8150.c  (mode:100644)
+++ uncommitted/drivers/usb/net/rtl8150.c  (mode:100644)
@@ -667,7 +667,7 @@
 	if (netdev->flags & IFF_PROMISC) {
 		dev->rx_creg |= cpu_to_le16(0x0001);
 		info("%s: promiscuous mode", netdev->name);
-	} else if ((netdev->mc_count > multicast_filter_limit) ||
+	} else if (netdev->mc_count ||
 		   (netdev->flags & IFF_ALLMULTI)) {
 		dev->rx_creg &= cpu_to_le16(0xfffe);
 		dev->rx_creg |= cpu_to_le16(0x0002);

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
