From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 11/11] carl9170: use ether_addr_equal_64bits
Date: Mon, 30 Dec 2013 19:15:07 +0100
Message-ID: <1388427307-8691-12-git-send-email-Julia.Lawall@lip6.fr>
References: <1388427307-8691-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Christian Lamparter <chunkeey@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:37280 "EHLO
	mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756218Ab3L3RTJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Dec 2013 12:19:09 -0500
In-Reply-To: <1388427307-8691-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <Julia.Lawall@lip6.fr>

Ether_addr_equal_64bits is more efficient than ether_addr_equal, and can be
used when each argument is an array within a structure that contains at
least two bytes of data beyond the array.

The structures involved are:
ieee80211_hdr defined in include/linux/ieee80211.h,
ieee80211_bar defined in include/linux/ieee80211.h and
ath_common defined in drivers/net/wireless/ath/ath.h

This was done using Coccinelle (http://coccinelle.lip6.fr/).

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
The semantic patch used is rather long and can be found in message 0 of
this patch series.

 drivers/net/wireless/ath/carl9170/rx.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/ath/carl9170/rx.c b/drivers/net/wireless/ath/carl9170/rx.c
index e935f61..acd7ddc 100644
--- a/drivers/net/wireless/ath/carl9170/rx.c
+++ b/drivers/net/wireless/ath/carl9170/rx.c
@@ -536,7 +536,7 @@ static void carl9170_ps_beacon(struct ar9170 *ar, void *data, unsigned int len)
 		return;
 
 	/* and only beacons from the associated BSSID, please */
-	if (!ether_addr_equal(hdr->addr3, ar->common.curbssid) ||
+	if (!ether_addr_equal_64bits(hdr->addr3, ar->common.curbssid) ||
 	    !ar->common.curaid)
 		return;
 
@@ -602,8 +602,8 @@ static void carl9170_ba_check(struct ar9170 *ar, void *data, unsigned int len)
 
 		if (bar->start_seq_num == entry_bar->start_seq_num &&
 		    TID_CHECK(bar->control, entry_bar->control) &&
-		    ether_addr_equal(bar->ra, entry_bar->ta) &&
-		    ether_addr_equal(bar->ta, entry_bar->ra)) {
+		    ether_addr_equal_64bits(bar->ra, entry_bar->ta) &&
+		    ether_addr_equal_64bits(bar->ta, entry_bar->ra)) {
 			struct ieee80211_tx_info *tx_info;
 
 			tx_info = IEEE80211_SKB_CB(entry_skb);
