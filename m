From: margitsw@t-online.de (Margit Schubert-While)
Subject: [PATCH 15/17 linux-2.6.7-rc2] prism54: Fix channel stats, bump version to 1.2 (resend)
Date: Sat, 5 Jun 2004 14:51:07 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406051451.07953.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_7GcwAXNDN/WMQKP"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-00=_7GcwAXNDN/WMQKP
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

2004-05-20      Aurelien Alleaume <slts@free.fr>

* islpci_eth.c : use dev_kfree_skb_irq instead of dev_kfree_skb where needed.

* isl_ioctl.c : report channel instead of frequency in scan.

* islpci_hotplug.c : bump version to 1.2



--Boundary-00=_7GcwAXNDN/WMQKP
Content-Type: text/x-diff;
  charset="us-ascii";
  name="15-fix-channel.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="15-fix-channel.patch"

diff -NaurEbB linux-2.6.6ct/drivers/net/wireless/prism54/isl_ioctl.c linux-2.6.6-01/drivers/net/wireless/prism54/isl_ioctl.c
--- linux-2.6.6ct/drivers/net/wireless/prism54/isl_ioctl.c	2004-05-28 15:44:40.849580016 +0200
+++ linux-2.6.6-01/drivers/net/wireless/prism54/isl_ioctl.c	2004-05-28 15:49:40.516023792 +0200
@@ -632,8 +629,8 @@
 	current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, NULL);
 
 	/* Add frequency. (short) bss->channel is the frequency in MHz */
-	iwe.u.freq.m = bss->channel;
-	iwe.u.freq.e = 6;
+	iwe.u.freq.m = channel_of_freq(bss->channel);
+	iwe.u.freq.e = 0;
 	iwe.cmd = SIOCGIWFREQ;
 	current_ev =
 	    iwe_stream_add_event(current_ev, end_buf, &iwe, IW_EV_FREQ_LEN);
diff -NaurEbB linux-2.6.6ct/drivers/net/wireless/prism54/islpci_eth.c linux-2.6.6-01/drivers/net/wireless/prism54/islpci_eth.c
--- linux-2.6.6ct/drivers/net/wireless/prism54/islpci_eth.c	2004-05-28 15:48:34.157111880 +0200
+++ linux-2.6.6-01/drivers/net/wireless/prism54/islpci_eth.c	2004-05-28 15:49:40.517023640 +0200
@@ -275,7 +275,7 @@
 									 avs_80211_1_header),
 								 0, GFP_ATOMIC);
 			if (newskb) {
-				kfree_skb(*skb);
+				dev_kfree_skb_irq(*skb);
 				*skb = newskb;
 			} else
 				return -1;
@@ -419,7 +419,7 @@
 	     skb->data[4], skb->data[5]);
 #endif
 	if (unlikely(discard)) {
-		dev_kfree_skb(skb);
+		dev_kfree_skb_irq(skb);
 		skb = NULL;
 	} else
 		netif_rx(skb);
@@ -462,7 +462,7 @@
 			      "Error mapping DMA address\n");
 
 			/* free the skbuf structure before aborting */
-			dev_kfree_skb((struct sk_buff *) skb);
+			dev_kfree_skb_irq((struct sk_buff *) skb);
 			skb = NULL;
 			break;
 		}
diff -NaurEbB linux-2.6.6ct/drivers/net/wireless/prism54/islpci_hotplug.c linux-2.6.6-01/drivers/net/wireless/prism54/islpci_hotplug.c
--- linux-2.6.6ct/drivers/net/wireless/prism54/islpci_hotplug.c	2004-05-28 14:40:26.997454592 +0200
+++ linux-2.6.6-01/drivers/net/wireless/prism54/islpci_hotplug.c	2004-05-28 15:49:40.519023336 +0200
@@ -30,7 +30,7 @@
 #include "isl_oid.h"
 
 #define DRV_NAME	"prism54"
-#define DRV_VERSION	"1.1"
+#define DRV_VERSION	"1.2"
 
 MODULE_AUTHOR("[Intersil] R.Bastings and W.Termorshuizen, The prism54.org Development Team <prism54-devel@prism54.org>");
 MODULE_DESCRIPTION("The Prism54 802.11 Wireless LAN adapter");

--Boundary-00=_7GcwAXNDN/WMQKP--
