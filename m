From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH 3/3] Generic HDLC - use random_ether_addr()
Date: Fri, 01 Feb 2008 22:39:50 +0100
Message-ID: <m37ihonyop.fsf@maximus.localdomain>
References: <m3ejbwnz2e.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:50085 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753420AbYBAVjw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2008 16:39:52 -0500
In-Reply-To: <m3ejbwnz2e.fsf@maximus.localdomain> (Krzysztof Halasa's message of "Fri\, 01 Feb 2008 22\:31\:37 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Generic HDLC now uses random_ether_addr() for generating MAC addresse
for Ethernet-alike interfaces.

Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>

diff --git a/drivers/net/wan/hdlc_fr.c b/drivers/net/wan/hdlc_fr.c
index 071a64c..7926842 100644
--- a/drivers/net/wan/hdlc_fr.c
+++ b/drivers/net/wan/hdlc_fr.c
@@ -42,7 +42,6 @@
 #include <linux/init.h>
 #include <linux/skbuff.h>
 #include <linux/pkt_sched.h>
-#include <linux/random.h>
 #include <linux/inetdevice.h>
 #include <linux/lapb.h>
 #include <linux/rtnetlink.h>
@@ -1122,10 +1121,9 @@ static int fr_add_pvc(struct net_device *frad, unsigned int dlci, int type)
 		return -ENOBUFS;
 	}
 
-	if (type == ARPHRD_ETHER) {
-		memcpy(dev->dev_addr, "\x00\x01", 2);
-                get_random_bytes(dev->dev_addr + 2, ETH_ALEN - 2);
-	} else {
+	if (type == ARPHRD_ETHER)
+		random_ether_addr(dev->dev_addr);
+	else {
 		*(__be16*)dev->dev_addr = htons(dlci);
 		dlci_to_q922(dev->broadcast, dlci);
 	}
diff --git a/drivers/net/wan/hdlc_raw_eth.c b/drivers/net/wan/hdlc_raw_eth.c
index 1a69a9a..104de6f 100644
--- a/drivers/net/wan/hdlc_raw_eth.c
+++ b/drivers/net/wan/hdlc_raw_eth.c
@@ -18,7 +18,6 @@
 #include <linux/init.h>
 #include <linux/skbuff.h>
 #include <linux/pkt_sched.h>
-#include <linux/random.h>
 #include <linux/inetdevice.h>
 #include <linux/lapb.h>
 #include <linux/rtnetlink.h>
@@ -107,8 +106,7 @@ static int raw_eth_ioctl(struct net_device *dev, struct ifreq *ifr)
 		ether_setup(dev);
 		dev->change_mtu = old_ch_mtu;
 		dev->tx_queue_len = old_qlen;
-		memcpy(dev->dev_addr, "\x00\x01", 2);
-                get_random_bytes(dev->dev_addr + 2, ETH_ALEN - 2);
+		random_ether_addr(dev->dev_addr);
 		netif_dormant_off(dev);
 		return 0;
 	}
