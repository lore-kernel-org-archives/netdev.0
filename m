From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 10/11] at76c50x-usb: use ether_addr_equal_64bits
Date: Mon, 30 Dec 2013 19:15:06 +0100
Message-ID: <1388427307-8691-11-git-send-email-Julia.Lawall@lip6.fr>
References: <1388427307-8691-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:37279 "EHLO
	mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756217Ab3L3RTJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Dec 2013 12:19:09 -0500
In-Reply-To: <1388427307-8691-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <Julia.Lawall@lip6.fr>

Ether_addr_equal_64bits is more efficient than ether_addr_equal, and can be
used when each argument is an array within a structure that contains at
least two bytes of data beyond the array.

The structures involved are:
at76_priv defined in drivers/net/wireless/at76c50x-usb.h and
ieee80211_mgmt defined in include/linux/ieee80211.h

This was done using Coccinelle (http://coccinelle.lip6.fr/).

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
The semantic patch used is rather long and can be found in message 0 of
this patch series.

 drivers/net/wireless/at76c50x-usb.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/at76c50x-usb.c b/drivers/net/wireless/at76c50x-usb.c
index 34c8a33..031d4ec 100644
--- a/drivers/net/wireless/at76c50x-usb.c
+++ b/drivers/net/wireless/at76c50x-usb.c
@@ -1721,7 +1721,7 @@ static void at76_mac80211_tx(struct ieee80211_hw *hw,
 	 * following workaround is necessary. If the TX frame is an
 	 * authentication frame extract the bssid and send the CMD_JOIN. */
 	if (mgmt->frame_control & cpu_to_le16(IEEE80211_STYPE_AUTH)) {
-		if (!ether_addr_equal(priv->bssid, mgmt->bssid)) {
+		if (!ether_addr_equal_64bits(priv->bssid, mgmt->bssid)) {
 			memcpy(priv->bssid, mgmt->bssid, ETH_ALEN);
 			ieee80211_queue_work(hw, &priv->work_join_bssid);
 			dev_kfree_skb_any(skb);
