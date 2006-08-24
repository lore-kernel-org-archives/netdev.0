From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 3/4] Try 2: Modify adm8211-d80211 to use wireless statistics
Date: Wed, 23 Aug 2006 22:02:25 -0500
Message-ID: <44ED16C1.2020400@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:32969 "EHLO
	mtiwmhc12.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1030229AbWHXDC3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 23:02:29 -0400
To: Jiri Benc <jbenc@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches modify adm8211-d80211 to use the wireless statics added in patch 1.

Signed-Off-By: Larry Finger@lwfinger.net>

======================================


diff --git a/drivers/net/wireless/d80211/adm8211/adm8211.c 
b/drivers/net/wireless/d80211/adm8211/adm8211.c
index dcabeab..5f13e9e 100644
--- a/drivers/net/wireless/d80211/adm8211/adm8211.c
+++ b/drivers/net/wireless/d80211/adm8211/adm8211.c
@@ -74,6 +74,8 @@ #define PLCP_SIGNAL_2M		0x14
  #define PLCP_SIGNAL_5M5		0x37
  #define PLCP_SIGNAL_11M		0x6e

+#define ADM8211_RX_MAX_SSI	100
+
  struct adm8211_tx_hdr {
  	u8 da[6];
  	u8 signal; /* PLCP signal / TX rate in 100 Kbps */
@@ -558,6 +560,14 @@ static void adm8211_interrupt_rci(struct
  			if (dev->flags & IFF_PROMISC)
  				skb_trim(skb, skb->len - FCS_LEN);

+
+/* FIXME: The following set of assignments supply additional data for wireless statistics. The
+	  necessary quantities are (1) the "noise" value in dBm, and (2) the "signal" value in dBm.
+	  The present code supplies dummy values for these quantities. */
+
+			rx_status.noise = -85;   /* FIXME */
+			rx_status.signal = rx_status.ssi - ADM8211_RX_MAX_SSI; /* FIXME */
+
  			ieee80211_rx_irqsafe(dev, skb, &rx_status);
  		}

@@ -2047,6 +2057,7 @@ #endif
  	hw->get_tsf = adm8211_get_tsft;
  	hw->get_tx_stats = adm8211_get_tx_stats;
  	hw->queues = 1;		// ADM8211C supports more, maybe ADM8211B
+	hw->maxssi = ADM8211_RX_MAX_SSI;// FIXME - This is an approximation

  	priv->retry_limit = 3;
  	priv->ant_power = 0x40;
