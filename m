From: Adrian Bunk <bunk@stusta.de>
Subject: [RFC: 2.6 patch] hostap_80211_rx(): fix a use-after-free
Date: Mon, 6 Nov 2006 15:21:48 +0100
Message-ID: <20061106142148.GO5778@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753103AbWKFOWN@vger.kernel.org>
To: linville@tuxdriver.com
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes a use-after-free for "skb" spotted by the Coverity 
checker.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6/drivers/net/wireless/hostap/hostap_80211_rx.c.old	2006-11-06 14:51:36.000000000 +0100
+++ linux-2.6/drivers/net/wireless/hostap/hostap_80211_rx.c	2006-11-06 14:52:16.000000000 +0100
@@ -1004,10 +1004,10 @@ void hostap_80211_rx(struct net_device *
 			if (local->hostapd && local->apdev) {
 				/* Send IEEE 802.1X frames to the user
 				 * space daemon for processing */
-				prism2_rx_80211(local->apdev, skb, rx_stats,
-						PRISM2_RX_MGMT);
 				local->apdevstats.rx_packets++;
 				local->apdevstats.rx_bytes += skb->len;
+				prism2_rx_80211(local->apdev, skb, rx_stats,
+						PRISM2_RX_MGMT);
 				goto rx_exit;
 			}
 		} else if (!frame_authorized) {
