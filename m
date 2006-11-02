From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 3/4] adm8211-d80211: Add wireless statistics (compile
	tested only)
Date: Thu, 02 Nov 2006 12:47:40 -0600
Message-ID: <454A3D4C.mail4SI11B3NB@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org, Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>,
	rt2400-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

These patches modify adm8211-d80211 to use the wireless statics added in patch 1.

Signed-Off-By: Larry Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Index: wireless-dev/drivers/net/wireless/d80211/adm8211/adm8211.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/adm8211/adm8211.c
+++ wireless-dev/drivers/net/wireless/d80211/adm8211/adm8211.c
@@ -73,6 +73,8 @@ ADM8211_IER_TDUIE | ADM8211_IER_GPTIE)
 #define PLCP_SIGNAL_5M5		0x37
 #define PLCP_SIGNAL_11M		0x6e
 
+#define ADM8211_RX_MAX_SSI	100
+
 struct adm8211_tx_hdr {
 	u8 da[6];
 	u8 signal; /* PLCP signal / TX rate in 100 Kbps */
@@ -557,6 +559,14 @@ static void adm8211_interrupt_rci(struct
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
 
@@ -2045,6 +2055,7 @@ static int __devinit adm8211_probe(struc
 	hw->get_tsf = adm8211_get_tsft;
 	hw->get_tx_stats = adm8211_get_tx_stats;
 	hw->queues = 1;		// ADM8211C supports more, maybe ADM8211B
+	hw->maxssi = ADM8211_RX_MAX_SSI;// FIXME - This is an approximation
 
 	priv->retry_limit = 3;
 	priv->ant_power = 0x40;
