From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: [PATCH wireless-2.6 6/12] Host AP: Prevent STAs from associating using AP address
Date: Sun, 7 Nov 2004 23:13:45 -0800
Message-ID: <20041108071345.GG1076@jm.kir.nu>
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

Prevent STAs from authenticating with AP address (i.e., spoofing AP
MAC address). The inner bridge implementation intercepts packets
before they are passed to Linux net stack, so using AP MAC address
would prevent AP from seeing the packet properly.

Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>


diff -Nru a/drivers/net/wireless/hostap/hostap_ap.c b/drivers/net/wireless/hostap/hostap_ap.c
--- a/drivers/net/wireless/hostap/hostap_ap.c	2004-11-07 22:38:35 -08:00
+++ b/drivers/net/wireless/hostap/hostap_ap.c	2004-11-07 22:38:35 -08:00
@@ -1329,7 +1329,8 @@
 	status_code = __le16_to_cpu(*pos);
 	pos++;
 
-	if (ap_control_mac_deny(&ap->mac_restrictions, hdr->addr2)) {
+	if (memcmp(dev->dev_addr, hdr->addr2, ETH_ALEN) == 0 ||
+	    ap_control_mac_deny(&ap->mac_restrictions, hdr->addr2)) {
 		txt = "authentication denied";
 		resp = WLAN_STATUS_UNSPECIFIED_FAILURE;
 		goto fail;


-- 
Jouni Malinen                                            PGP id EFC895FA
