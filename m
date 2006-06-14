From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] bcm43xx: use softmac-suggested TX rate
Date: Wed, 14 Jun 2006 17:51:14 +0200
Message-ID: <200606141751.15205.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bcm43xx-dev@lists.berlios.de,
	Daniel Drake <dsd@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:17107
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S965014AbWFNPxS
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jun 2006 11:53:18 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi John,

Sorry, took a little bit longer than expected, but here it is. :)
Please queue for 2.6.18.

--

From: Daniel Drake <dsd@gentoo.org>

Use Softmac-suggested TX ratecode:
ieee80211softmac_suggest_txrate()

Signed-off-by: Daniel Drake <dsd@gentoo.org>
Signed-off-by: Michael Buesch <mb@bu3sch.de>

Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c	2006-06-14 16:53:50.000000000 +0200
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c	2006-06-14 17:44:23.000000000 +0200
@@ -296,11 +296,14 @@
 	u16 control = 0;
 	u16 wsec_rate = 0;
 	u16 encrypt_frame;
+	const u16 ftype = WLAN_FC_GET_TYPE(le16_to_cpu(wireless_header->frame_ctl));
+	const int is_mgt = (ftype == IEEE80211_FTYPE_MGMT);
 
 	/* Now construct the TX header. */
 	memset(txhdr, 0, sizeof(*txhdr));
 
-	bitrate = bcm->softmac->txrates.default_rate;
+	bitrate = ieee80211softmac_suggest_txrate(bcm->softmac,
+		is_multicast_ether_addr(wireless_header->addr1), is_mgt);
 	ofdm_modulation = !(ieee80211_is_cck_rate(bitrate));
 	fallback_bitrate = bcm43xx_calc_fallback_rate(bitrate);
 	fallback_ofdm_modulation = !(ieee80211_is_cck_rate(fallback_bitrate));

-- 
Greetings Michael.
