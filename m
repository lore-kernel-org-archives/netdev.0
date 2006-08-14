From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] Add wireless statistics code to d80211 versions of adm8211
 and rt2x00 drivers
Date: Mon, 14 Aug 2006 13:51:11 -0500
Message-ID: <44E0C61F.1020507@lwfinger.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040802080401040405030102"
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:7047 "EHLO
	mtiwmhc13.worldnet.att.net") by vger.kernel.org with ESMTP
	id S932235AbWHNSvM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 14:51:12 -0400
To: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org,
	Ivo van Doorn <ivdoorn@gmail.com>,
	Michael Wu <flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040802080401040405030102
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch adds the necessary bits to the adm8211 and rt2x00 family of drivers 
for them to report wireless statistics to the d80211 stack in the wireless-dev 
tree. At present as discussed with Ivo van Doorn (rt2x00) and Michael Wu 
(adm2311), the needed values of maxssi, noise and signal are totally bogus, with 
prominent FIXME's. As the proper quantities are available, these sections will 
be changed.

This patch has been compile tested only. I do not have the necessary hardware. 
To preserve white space and prevent line wraps, the patch is attached.

Signed-Off-By: Larry Finger <Larry.Finger@lwfinger.net>


--------------040802080401040405030102
Content-Type: text/plain;
 name="patch_stats2"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch_stats2"

diff --git a/drivers/net/wireless/d80211/adm8211/adm8211.c b/drivers/net/wireless/d80211/adm8211/adm8211.c
index dcabeab..6845f40 100644
--- a/drivers/net/wireless/d80211/adm8211/adm8211.c
+++ b/drivers/net/wireless/d80211/adm8211/adm8211.c
@@ -558,6 +558,16 @@ static void adm8211_interrupt_rci(struct
 			if (dev->flags & IFF_PROMISC)
 				skb_trim(skb, skb->len - FCS_LEN);
 
+
+/* FIXME: The following set of assignments supply additional data for wireless statistics. The
+	  necessary quantities are (1) "maxssi", the maximum value ssi (above) can reach,
+	  (2) the "noise" value in dBm, and (3) the "signal" value in dBm. The present code
+	  supplies dummy values for these three quantities. */
+
+			rx_status.maxssi = 100;  /* FIXME */
+			rx_status.noise = -85;   /* FIXME */
+			rx_status.signal = rx_status.ssi - rx_status.maxssi; /* FIXME */
+
 			ieee80211_rx_irqsafe(dev, skb, &rx_status);
 		}
 
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2400pci.c b/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
index 96bcdf4..38b655c 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
@@ -1746,6 +1746,16 @@ static void rt2400pci_rxdone(void *data)
 			rt2x00dev->rx_params.ssi =
 				rt2x00_get_field32(rxd->word2, RXD_W2_RSSI);
 
+/* FIXME: The following set of assignments supply additional data for wireless statistics. The
+	  necessary quantities are (1) "maxssi", the maximum value ssi (above) can reach,
+	  (2) the "noise" value in dBm, and (3) the "signal" value in dBm. The present code
+	  supplies dummy values for these three quantities. */
+
+			rt2x00dev->rx_params.maxssi = 100;  /* FIXME */
+			rt2x00dev->rx_params.noise = -85;   /* FIXME */
+			rt2x00dev->rx_params.signal =
+				rt2x00dev->rx_params.ssi - rt2x00dev->rx_params.maxssi; /* FIXME */
+
 			__ieee80211_rx(ring->net_dev,
 				skb, &rt2x00dev->rx_params);
 		}
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2500pci.c b/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
index 20095aa..40b543d 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
@@ -1890,6 +1890,16 @@ static void rt2500pci_rxdone(void *data)
 			rt2x00dev->rx_params.ssi =
 				rt2x00_get_field32(rxd->word2, RXD_W2_RSSI);
 
+/* FIXME: The following set of assignments supply additional data for wireless statistics. The
+	  necessary quantities are (1) "maxssi", the maximum value ssi (above) can reach,
+	  (2) the "noise" value in dBm, and (3) the "signal" value in dBm. The present code
+	  supplies dummy values for these three quantities. */
+
+			rt2x00dev->rx_params.maxssi = 100;  /* FIXME */
+			rt2x00dev->rx_params.noise = -85;   /* FIXME */
+			rt2x00dev->rx_params.signal =
+				rt2x00dev->rx_params.ssi - rt2x00dev->rx_params.maxssi; /* FIXME */
+
 			__ieee80211_rx(ring->net_dev,
 				skb, &rt2x00dev->rx_params);
 
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2500usb.c b/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
index 383f4a9..f375c52 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
@@ -1623,6 +1623,16 @@ static void rt2500usb_rxdone(void *data)
 			rt2x00dev->rx_params.ssi =
 				rt2x00_get_field32(rxd->word1, RXD_W1_RSSI);
 
+/* FIXME: The following set of assignments supply additional data for wireless statistics. The
+	  necessary quantities are (1) "maxssi", the maximum value ssi (above) can reach,
+	  (2) the "noise" value in dBm, and (3) the "signal" value in dBm. The present code
+	  supplies dummy values for these three quantities. */
+
+			rt2x00dev->rx_params.maxssi = 100;  /* FIXME */
+			rt2x00dev->rx_params.noise = -85;   /* FIXME */
+			rt2x00dev->rx_params.signal =
+				rt2x00dev->rx_params.ssi - rt2x00dev->rx_params.maxssi; /* FIXME */
+
 			__ieee80211_rx(ring->net_dev,
 				skb, &rt2x00dev->rx_params);
 
diff --git a/drivers/net/wireless/d80211/rt2x00/rt61pci.c b/drivers/net/wireless/d80211/rt2x00/rt61pci.c
index cc6789e..5d2a9ff 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt61pci.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt61pci.c
@@ -2337,6 +2337,16 @@ static void rt61pci_rxdone(void *data)
 			rt2x00dev->rx_params.ssi =
 				rt2x00_get_field32(rxd->word1, RXD_W1_RSSI);
 
+/* FIXME: The following set of assignments supply additional data for wireless statistics. The
+	  necessary quantities are (1) "maxssi", the maximum value ssi (above) can reach,
+	  (2) the "noise" value in dBm, and (3) the "signal" value in dBm. The present code
+	  supplies dummy values for these three quantities. */
+
+			rt2x00dev->rx_params.maxssi = 100;  /* FIXME */
+			rt2x00dev->rx_params.noise = -85;   /* FIXME */
+			rt2x00dev->rx_params.signal =
+				rt2x00dev->rx_params.ssi - rt2x00dev->rx_params.maxssi; /* FIXME */
+
 			__ieee80211_rx(ring->net_dev,
 				skb, &rt2x00dev->rx_params);
 
diff --git a/drivers/net/wireless/d80211/rt2x00/rt73usb.c b/drivers/net/wireless/d80211/rt2x00/rt73usb.c
index 682d078..5a90fb9 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt73usb.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt73usb.c
@@ -1907,6 +1907,16 @@ static void rt73usb_rxdone(void *data)
 			rt2x00dev->rx_params.ssi =
 				rt2x00_get_field32(rxd->word1, RXD_W1_RSSI);
 
+/* FIXME: The following set of assignments supply additional data for wireless statistics. The
+	  necessary quantities are (1) "maxssi", the maximum value ssi (above) can reach,
+	  (2) the "noise" value in dBm, and (3) the "signal" value in dBm. The present code
+	  supplies dummy values for these three quantities. */
+
+			rt2x00dev->rx_params.maxssi = 100;  /* FIXME */
+			rt2x00dev->rx_params.noise = -85;   /* FIXME */
+			rt2x00dev->rx_params.signal =
+				rt2x00dev->rx_params.ssi - rt2x00dev->rx_params.maxssi; /* FIXME */
+
 			__ieee80211_rx(ring->net_dev,
 				skb, &rt2x00dev->rx_params);
 

--------------040802080401040405030102--
