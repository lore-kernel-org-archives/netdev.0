From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 6/8] d80211/bcm43xx: Modify bcm43xx_xmit.c for wireless statistics.
Date: Tue, 08 Aug 2006 18:59:47 -0500
Message-ID: <44D92573.8070002@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:11726 "EHLO
	mtiwmhc11.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1030354AbWHHX7w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 19:59:52 -0400
To: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Part 6 of 8 to add wireless statistics to the bcm43xx-d80211 system.
This patch stores the new variables in 'status' for transmission to
ieee80211.

The patch is for the August 8 version of Linville's wireless-dev tree.

Signed-Off-By: Larry Finger <Larry.Finger@lwfinger.net>


diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c
index 3f86079..90776b2 100644
--- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c
+++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c
@@ -475,7 +475,10 @@ void bcm43xx_rx(struct bcm43xx_private *
  	 */

  	memset(&status, 0, sizeof(status));
-	status.ssi = bcm43xx_rssi_postprocess(bcm, rxhdr->rssi, is_ofdm,
+	status.noise = bcm->stats.link_noise;
+	status.ssi = rxhdr->rssi;
+	status.maxssi = BCM43xx_RX_MAX_SSI;
+	status.signal = bcm43xx_rssi_postprocess(bcm, rxhdr->rssi, is_ofdm,
  					      !!(rxflags1 & BCM43xx_RXHDR_FLAGS1_2053RSSIADJ),
  					      !!(rxflags3 & BCM43xx_RXHDR_FLAGS3_2050RSSIADJ));
  	if (is_ofdm)



