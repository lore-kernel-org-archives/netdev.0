From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: [PATCH wireless-2.6 3/12] Host AP: Ignore (Re)AssocResp messages silently
Date: Sun, 7 Nov 2004 23:12:11 -0800
Message-ID: <20041108071211.GD1076@jm.kir.nu>
References: <20041108070156.GA1076@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20041108070156.GA1076@jm.kir.nu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ignore (Re)AssocResp silently since these are not currently needed but
are still received when WPA/RSN mode is enabled.

Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>


diff -Nru a/drivers/net/wireless/hostap/hostap_80211_rx.c b/drivers/net/wireless/hostap/hostap_80211_rx.c
--- a/drivers/net/wireless/hostap/hostap_80211_rx.c	2004-11-07 22:38:11 -08:00
+++ b/drivers/net/wireless/hostap/hostap_80211_rx.c	2004-11-07 22:38:11 -08:00
@@ -475,6 +475,13 @@
 		    stype == WLAN_FC_STYPE_PROBE_RESP)) {
 		hostap_rx_sta_beacon(local, skb, stype);
 		return -1;
+	} else if (type == WLAN_FC_TYPE_MGMT &&
+		   (stype == WLAN_FC_STYPE_ASSOC_RESP ||
+		    stype == WLAN_FC_STYPE_REASSOC_RESP)) {
+		/* Ignore (Re)AssocResp silently since these are not currently
+		 * needed but are still received when WPA/RSN mode is enabled.
+		 */
+		return -1;
 	} else {
 		printk(KERN_DEBUG "%s: hostap_rx_frame_mgmt: dropped unhandled"
 		       " management frame in non-Host AP mode (type=%d:%d)\n",


-- 
Jouni Malinen                                            PGP id EFC895FA
