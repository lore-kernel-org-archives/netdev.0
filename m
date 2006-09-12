From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] bcm43xx-softmac: update noise handling
Date: Tue, 12 Sep 2006 12:40:32 -0500
Message-ID: <4506F110.mailATA11P27W@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	Bcm43xx-dev@lists.berlios.de, Stefano Brivio <st3@riseup.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ms-smtp-03.rdc-kc.rr.com ([24.94.166.129]:51387 "EHLO
	ms-smtp-03.rdc-kc.rr.com") by vger.kernel.org with ESMTP
	id S1030297AbWILRlD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Sep 2006 13:41:03 -0400
To: John Linville <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John,

Please apply this patch to wireless-2.6. In addition, please let me
know if you have any problems applying it. I'm sending this by a new
method.

Larry

In bcm43xx-softmac, the bcm43xx_stats struct contains a variable that
is no longer used. In addition, two TODO entries related to noise
processing in bcm43xx_rx have been completed, and as unused one
is removed.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---

Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx.h
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx.h
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx.h
@@ -666,7 +666,6 @@ struct bcm43xx_noise_calculation {
 };
 
 struct bcm43xx_stats {
-	u8 link_quality;
 	u8 noise;
 	struct iw_statistics wstats;
 	/* Store the last TX/RX times here for updating the leds. */
Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
@@ -496,15 +496,14 @@ int bcm43xx_rx(struct bcm43xx_private *b
 	stats.signal = bcm43xx_rssi_postprocess(bcm, rxhdr->rssi, is_ofdm,
 					      !!(rxflags1 & BCM43xx_RXHDR_FLAGS1_2053RSSIADJ),
 					      !!(rxflags3 & BCM43xx_RXHDR_FLAGS3_2050RSSIADJ));
-//TODO	stats.noise = 
+	stats.noise = bcm->stats.noise;
 	if (is_ofdm)
 		stats.rate = bcm43xx_plcp_get_bitrate_ofdm(plcp);
 	else
 		stats.rate = bcm43xx_plcp_get_bitrate_cck(plcp);
 	stats.received_channel = radio->channel;
-//TODO	stats.control = 
 	stats.mask = IEEE80211_STATMASK_SIGNAL |
-//TODO		     IEEE80211_STATMASK_NOISE |
+		     IEEE80211_STATMASK_NOISE |
 		     IEEE80211_STATMASK_RATE |
 		     IEEE80211_STATMASK_RSSI;
 	if (phy->type == BCM43xx_PHYTYPE_A)
