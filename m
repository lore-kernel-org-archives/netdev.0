From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw: Fixed array size issue in reset_mode
Date: Mon, 29 Jan 2007 00:59:40 +0000 (GMT)
Message-ID: <20070129005940.501D77B40A0@zog.reactivated.net>
Cc: netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout03-winn.ispmail.ntl.com ([81.103.221.49]:13169 "EHLO
	mtaout03-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933012AbXA2A7f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jan 2007 19:59:35 -0500
Cc: kune@deine-taler.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ulrich Kunitz <kune@deine-taler.de>

Andy Green found this issue.

Signed-off-by: Daniel Drake <dsd@gentoo.org>
---
 zd_mac.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

Index: linux/drivers/net/wireless/zd1211rw/zd_mac.c
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_mac.c
+++ linux/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -156,7 +156,7 @@ void zd_mac_clear(struct zd_mac *mac)
 static int reset_mode(struct zd_mac *mac)
 {
 	struct ieee80211_device *ieee = zd_mac_to_ieee80211(mac);
-	struct zd_ioreq32 ioreqs[3] = {
+	struct zd_ioreq32 ioreqs[] = {
 		{ CR_RX_FILTER, STA_RX_FILTER },
 		{ CR_SNIFFER_ON, 0U },
 	};
@@ -164,10 +164,9 @@ static int reset_mode(struct zd_mac *mac
 	if (ieee->iw_mode == IW_MODE_MONITOR) {
 		ioreqs[0].value = 0xffffffff;
 		ioreqs[1].value = 0x1;
-		ioreqs[2].value = ENC_SNIFFER;
 	}
 
-	return zd_iowrite32a(&mac->chip, ioreqs, 3);
+	return zd_iowrite32a(&mac->chip, ioreqs, ARRAY_SIZE(ioreqs));
 }
 
 int zd_mac_open(struct net_device *netdev)
