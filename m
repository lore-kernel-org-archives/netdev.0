From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 4/4] Try 2: Modify rt2x00-d80211 to use wireless statistics
Date: Wed, 23 Aug 2006 22:02:57 -0500
Message-ID: <44ED16E1.3040906@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:58759 "EHLO
	mtiwmhc13.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1030231AbWHXDDV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 23:03:21 -0400
To: Jiri Benc <jbenc@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches modify the rt2x00-d80211 family of drivers to use the wireless statics added in patch 1.

Signed-Off-By: Larry Finger@lwfinger.net>

======================================


diff --git a/drivers/net/wireless/d80211/rt2x00/rt2400pci.c 
b/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
index 00f3a66..4244e94 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
@@ -1709,6 +1709,14 @@ static void rt2400pci_rxdone(void *data)
  			rt2x00dev->rx_params.ssi =
  				rt2x00_get_field32(rxd->word2, RXD_W2_RSSI);

+/* FIXME: The following set of assignments supply additional data for wireless statistics. The
+          necessary quantities are (1) the "noise" value in dBm, and (2) the "signal" value in dBm.
+          The present code supplies dummy values for these quantities. */
+
+			rt2x00dev->rx_params.noise = -85;   /* FIXME */
+			rt2x00dev->rx_params.signal =
+				rt2x00dev->rx_params.ssi - RT2X00_RX_MAX_SSI; /* FIXME */
+
  			__ieee80211_rx(ring->net_dev,
  				skb, &rt2x00dev->rx_params);
  		}
@@ -2565,6 +2573,7 @@ static int rt2400pci_init_hw(struct rt2x
  	hw->device_strips_mic = 0;
  	hw->monitor_during_oper = 1;
  	hw->fraglist = 0;
+	hw->maxssi = RT2X00_RX_MAX_SSI;

  	/*
  	 * We have 2 TX queues: TX and PRIO.
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2500pci.c 
b/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
index 3f6dd94..16cffe0 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
@@ -1853,6 +1853,14 @@ static void rt2500pci_rxdone(void *data)
  			rt2x00dev->rx_params.ssi =
  				rt2x00_get_field32(rxd->word2, RXD_W2_RSSI);

+/* FIXME: The following set of assignments supply additional data for wireless statistics. The
+          necessary quantities are (1) the "noise" value in dBm, and (2) the "signal" value in dBm.
+          The present code supplies dummy values for these quantities. */
+
+			rt2x00dev->rx_params.noise = -85;   /* FIXME */
+			rt2x00dev->rx_params.signal =
+				rt2x00dev->rx_params.ssi - RT2X00_RX_MAX_SSI; /* FIXME */
+
  			__ieee80211_rx(ring->net_dev,
  				skb, &rt2x00dev->rx_params);

@@ -2717,6 +2725,7 @@ static int rt2500pci_init_hw(struct rt2x
  	hw->device_strips_mic = 0;
  	hw->monitor_during_oper = 1;
  	hw->fraglist = 0;
+	hw->maxssi = RT2X00_RX_MAX_SSI;

  	/*
  	 * We have 2 TX queues: TX and PRIO.
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2500usb.c 
b/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
index 383f4a9..f77ecd4 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
@@ -1623,6 +1623,14 @@ static void rt2500usb_rxdone(void *data)
  			rt2x00dev->rx_params.ssi =
  				rt2x00_get_field32(rxd->word1, RXD_W1_RSSI);

+/* FIXME: The following set of assignments supply additional data for wireless statistics. The
+	  necessary quantities are (1) the "noise" value in dBm, and (2) the "signal" value in dBm.
+	  The present code supplies dummy values for these quantities. */
+
+			rt2x00dev->rx_params.noise = -85;   /* FIXME */
+			rt2x00dev->rx_params.signal =
+				rt2x00dev->rx_params.ssi - RT2X00_RX_MAX_SSI; /* FIXME */
+
  			__ieee80211_rx(ring->net_dev,
  				skb, &rt2x00dev->rx_params);

@@ -2387,6 +2395,7 @@ static int rt2500usb_init_hw(struct rt2x
  	hw->device_strips_mic = 0;
  	hw->monitor_during_oper = 1;
  	hw->fraglist = 0;
+	hw->maxssi = RT2X00_RX_MAX_SSI;

  	/*
  	 * We have 2 TX queues: TX and PRIO.
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2x00.h b/drivers/net/wireless/d80211/rt2x00/rt2x00.h
index 89eee23..5669ef9 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt2x00.h
+++ b/drivers/net/wireless/d80211/rt2x00/rt2x00.h
@@ -826,6 +826,8 @@ #define CONFIG_EXTERNAL_LNA_BG		0x000080
  #define CONFIG_DOUBLE_ANTENNA		0x00010000
  #define CONFIG_DISABLE_BBP_TUNING	0x00020000

+#define RT2X00_RX_MAX_SSI		100
+
  	/*
  	 * Chipset identification.
  	 */
diff --git a/drivers/net/wireless/d80211/rt2x00/rt61pci.c b/drivers/net/wireless/d80211/rt2x00/rt61pci.c
index 2157ba2..fa6fec4 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt61pci.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt61pci.c
@@ -2300,6 +2300,14 @@ static void rt61pci_rxdone(void *data)
  			rt2x00dev->rx_params.ssi =
  				rt2x00_get_field32(rxd->word1, RXD_W1_RSSI);

+/* FIXME: The following set of assignments supply additional data for wireless statistics. The
+	  necessary quantities are (1) the "noise" value in dBm, and (2) the "signal" value in dBm.
+	  The present code supplies dummy values for these quantities. */
+
+			rt2x00dev->rx_params.noise = -85;   /* FIXME */
+			rt2x00dev->rx_params.signal =
+				rt2x00dev->rx_params.ssi - RT2X00_RX_MAX_SSI; /* FIXME */
+
  			__ieee80211_rx(ring->net_dev,
  				skb, &rt2x00dev->rx_params);

@@ -3242,6 +3250,7 @@ static int rt61pci_init_hw(struct rt2x00
  	hw->device_strips_mic = 0;
  	hw->monitor_during_oper = 1;
  	hw->fraglist = 0;
+	hw->maxssi = RT2X00_RX_MAX_SSI;

  	/*
  	 * We have full WMM capabilities.
diff --git a/drivers/net/wireless/d80211/rt2x00/rt73usb.c b/drivers/net/wireless/d80211/rt2x00/rt73usb.c
index 682d078..9ab54a9 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt73usb.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt73usb.c
@@ -1907,6 +1907,14 @@ static void rt73usb_rxdone(void *data)
  			rt2x00dev->rx_params.ssi =
  				rt2x00_get_field32(rxd->word1, RXD_W1_RSSI);

+/* FIXME: The following set of assignments supply additional data for wireless statistics. The
+	  necessary quantities are (1) the "noise" value in dBm, and (2) the "signal" value in dBm.
+	  The present code supplies dummy values for these quantities. */
+
+			rt2x00dev->rx_params.noise = -85;   /* FIXME */
+			rt2x00dev->rx_params.signal =
+				rt2x00dev->rx_params.ssi - RT2X00_RX_MAX_SSI; /* FIXME */
+
  			__ieee80211_rx(ring->net_dev,
  				skb, &rt2x00dev->rx_params);

@@ -2755,6 +2763,7 @@ static int rt73usb_init_hw(struct rt2x00
  	hw->device_strips_mic = 0;
  	hw->monitor_during_oper = 1;
  	hw->fraglist = 0;
+	hw->maxssi = RT2X00_RX_MAX_SSI;

  	/*
  	 * We have full WMM capabilities.
