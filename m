From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next] net/wireless: ipw2x00: Use helpers from linux/etherdevice.h
Date: Mon,  4 Jul 2011 12:00:22 +0200
Message-ID: <1309773622-28510-1-git-send-email-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:43293 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753824Ab1GDKAY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jul 2011 06:00:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/wireless/ipw2x00/libipw_rx.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ipw2x00/libipw_rx.c b/drivers/net/wireless/ipw2x00/libipw_rx.c
index e5ad76c..32a9966 100644
--- a/drivers/net/wireless/ipw2x00/libipw_rx.c
+++ b/drivers/net/wireless/ipw2x00/libipw_rx.c
@@ -442,7 +442,7 @@ int libipw_rx(struct libipw_device *ieee, struct sk_buff *skb,
 		 * 802.11, but makes it easier to use different keys with
 		 * stations that do not support WEP key mapping). */
 
-		if (!(hdr->addr1[0] & 0x01) || local->bcrx_sta_key)
+		if (is_unicast_ether_addr(hdr->addr1) || local->bcrx_sta_key)
 			(void)hostap_handle_sta_crypto(local, hdr, &crypt,
 						       &sta);
 #endif
@@ -772,7 +772,7 @@ int libipw_rx(struct libipw_device *ieee, struct sk_buff *skb,
 
 #ifdef NOT_YET
 	if (ieee->iw_mode == IW_MODE_MASTER && !wds && ieee->ap->bridge_packets) {
-		if (dst[0] & 0x01) {
+		if (is_multicast_ether_addr(dst)) {
 			/* copy multicast frame both to the higher layers and
 			 * to the wireless media */
 			ieee->ap->bridged_multicast++;
-- 
1.7.5.4

