From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw: Allow channels 1-13 in Japan
Date: Wed, 22 Nov 2006 00:06:32 +0000 (GMT)
Message-ID: <20061122000632.112B77B40A0@zog.reactivated.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout02-winn.ispmail.ntl.com ([81.103.221.48]:59840 "EHLO
	mtaout02-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1756890AbWKVAG0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Nov 2006 19:06:26 -0500
To: linville@tuxdriver.com
Cc: kune@deine-taler.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Goff found that he could not use his ZD1211 device which is
programmed for the Japan regulatory domain. It turns out that ZyDAS
deviate from the spec here: they do not use the newer Japan region code
(0x41) but their drivers do operate as if the newer Japan legal
frequency range is in effect.

Signed-off-by: Daniel Drake <dsd@gentoo.org>
---
 zd_ieee80211.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

Index: linux/drivers/net/wireless/zd1211rw/zd_ieee80211.c
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_ieee80211.c
+++ linux/drivers/net/wireless/zd1211rw/zd_ieee80211.c
@@ -37,7 +37,12 @@ static const struct channel_range channe
 	[ZD_REGDOMAIN_JAPAN]	 = { 1, 14},
 	[ZD_REGDOMAIN_SPAIN]	 = { 1, 14},
 	[ZD_REGDOMAIN_FRANCE]	 = { 1, 14},
-	[ZD_REGDOMAIN_JAPAN_ADD] = {14, 15},
+
+	/* Japan originally only had channel 14 available (see CHNL_ID 0x40 in
+	 * 802.11). However, in 2001 the range was extended to include channels
+	 * 1-13. The ZyDAS devices still use the old region code but are
+	 * designed to allow the extra channel access in Japan. */
+	[ZD_REGDOMAIN_JAPAN_ADD] = { 1, 15},
 };
 
 const struct channel_range *zd_channel_range(u8 regdomain)
