From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH,RFT] bcm43xx: use softmac-suggested TX rate
Date: Sat,  6 May 2006 10:16:51 +0100 (BST)
Message-ID: <20060506091651.26BCD88A2C3@zog.reactivated.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta07-winn.ispmail.ntl.com ([81.103.221.47]:11230 "EHLO
	mtaout01-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1751082AbWEFJQv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 May 2006 05:16:51 -0400
Received: from aamtaout01-winn.ispmail.ntl.com ([81.103.221.35])
          by mtaout01-winn.ispmail.ntl.com with ESMTP
          id <20060506091650.WFUQ29343.mtaout01-winn.ispmail.ntl.com@aamtaout01-winn.ispmail.ntl.com>
          for <netdev@vger.kernel.org>; Sat, 6 May 2006 10:16:50 +0100
Received: from zog.reactivated.net ([86.14.216.162])
          by aamtaout01-winn.ispmail.ntl.com with ESMTP
          id <20060506091650.DCMO19763.aamtaout01-winn.ispmail.ntl.com@zog.reactivated.net>
          for <netdev@vger.kernel.org>; Sat, 6 May 2006 10:16:50 +0100
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Can a bcm43xx user please test this. It uses the new txrate stuff found in
the wireless-dev tree.

Signed-off-by: Daniel Drake <dsd@gentoo.org>

Index: linux/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
===================================================================
--- linux.orig/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
+++ linux/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
@@ -296,11 +296,14 @@ void bcm43xx_generate_txhdr(struct bcm43
 	u16 control = 0;
 	u16 wsec_rate = 0;
 	u16 encrypt_frame;
+	u16 ftype = WLAN_FC_GET_TYPE(le16_to_cpu(wireless_header->frame_ctl));
+	int is_mgt = (ftype == IEEE80211_FTYPE_MGMT) != 0;
 
 	/* Now construct the TX header. */
 	memset(txhdr, 0, sizeof(*txhdr));
 
-	bitrate = bcm->softmac->txrates.default_rate;
+	bitrate = ieee80211softmac_suggest_txrate(bcm->softmac,
+		is_multicast_ether_addr(wireless_header->addr1), is_mgt);
 	ofdm_modulation = !(ieee80211_is_cck_rate(bitrate));
 	fallback_bitrate = bcm43xx_calc_fallback_rate(bitrate);
 	fallback_ofdm_modulation = !(ieee80211_is_cck_rate(fallback_bitrate));
