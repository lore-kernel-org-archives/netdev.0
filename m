From: margitsw@t-online.de (Margit Schubert-While)
Subject: [PATCH 7/17 linux-2.6.7-rc2] prism54: Fix endian patch (resend)
Date: Sat, 5 Jun 2004 14:48:49 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406051448.49243.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_xEcwAn8+ZGAgS1T"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-00=_xEcwAn8+ZGAgS1T
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

* Split out patch islpci_eth.c :
* Fix endian problem (bug 74/75 related)



--Boundary-00=_xEcwAn8+ZGAgS1T
Content-Type: text/x-diff;
  charset="us-ascii";
  name="07-fix-endian.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="07-fix-endian.patch"

diff -NaurEb linux-2.6.6ct/drivers/net/wireless/prism54/islpci_eth.c linux-2.6.6-01/drivers/net/wireless/prism54/islpci_eth.c
--- linux-2.6.6ct/drivers/net/wireless/prism54/islpci_eth.c	2004-05-28 14:40:26.996454744 +0200
+++ linux-2.6.6-01/drivers/net/wireless/prism54/islpci_eth.c	2004-05-28 14:25:30.065808928 +0200
@@ -262,9 +262,9 @@
 	if (priv->ndev->type == ARPHRD_IEEE80211_PRISM) {
 		struct avs_80211_1_header *avs;
 		/* extract the relevant data from the header */
-		u32 clock = hdr->clock;
+		u32 clock = le32_to_cpu(hdr->clock);
 		u8 rate = hdr->rate;
-		u16 freq = be16_to_cpu(hdr->freq);
+		u16 freq = le16_to_cpu(hdr->freq);
 		u8 rssi = hdr->rssi;
 
 		skb_pull(*skb, sizeof (struct rfmon_header));
@@ -288,20 +288,20 @@
 							   sizeof (struct
 								   avs_80211_1_header));
 
-		avs->version = htonl(P80211CAPTURE_VERSION);
-		avs->length = htonl(sizeof (struct avs_80211_1_header));
-		avs->mactime = __cpu_to_be64(clock);
-		avs->hosttime = __cpu_to_be64(jiffies);
-		avs->phytype = htonl(6);	/*OFDM: 6 for (g), 8 for (a) */
-		avs->channel = htonl(channel_of_freq(freq));
-		avs->datarate = htonl(rate * 5);
-		avs->antenna = htonl(0);	/*unknown */
-		avs->priority = htonl(0);	/*unknown */
-		avs->ssi_type = htonl(2);	/*2: dBm, 3: raw RSSI */
-		avs->ssi_signal = htonl(rssi);
-		avs->ssi_noise = htonl(priv->local_iwstatistics.qual.noise);	/*better than 'undefined', I assume */
-		avs->preamble = htonl(0);	/*unknown */
-		avs->encoding = htonl(0);	/*unknown */
+		avs->version = cpu_to_be32(P80211CAPTURE_VERSION);
+		avs->length = cpu_to_be32(sizeof (struct avs_80211_1_header));
+		avs->mactime = cpu_to_be64(le64_to_cpu(clock));
+		avs->hosttime = cpu_to_be64(jiffies);
+		avs->phytype = cpu_to_be32(6);	/*OFDM: 6 for (g), 8 for (a) */
+		avs->channel = cpu_to_be32(channel_of_freq(freq));
+		avs->datarate = cpu_to_be32(rate * 5);
+		avs->antenna = cpu_to_be32(0);	/*unknown */
+		avs->priority = cpu_to_be32(0);	/*unknown */
+		avs->ssi_type = cpu_to_be32(3);	/*2: dBm, 3: raw RSSI */
+		avs->ssi_signal = cpu_to_be32(rssi & 0x7f);
+		avs->ssi_noise = cpu_to_be32(priv->local_iwstatistics.qual.noise);	/*better than 'undefined', I assume */
+		avs->preamble = cpu_to_be32(0);	/*unknown */
+		avs->encoding = cpu_to_be32(0);	/*unknown */
 	} else
 		skb_pull(*skb, sizeof (struct rfmon_header));
 

--Boundary-00=_xEcwAn8+ZGAgS1T--
