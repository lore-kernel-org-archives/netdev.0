From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 7/8] d80211/bcm43xx: Modify struct ieee80211_rx_status for
 wireless statistics.
Date: Tue, 08 Aug 2006 18:59:59 -0500
Message-ID: <44D9257F.9000002@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:26752 "EHLO
	mtiwmhc13.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1030355AbWHIAAB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 20:00:01 -0400
To: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Part 7 of 8 to add wireless statistics to the bcm43xx-d80211 system.
This patch modifies ieee80211_rx_h_sta_process to transfer the new
status variables into struct sta_info.

The patch is for the August 8 version of Linville's wireless-dev tree.

Signed-Off-By: Larry Finger <Larry.Finger@lwfinger.net>

diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 60eca90..9cfbec1 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -3173,6 +3173,9 @@ ieee80211_rx_h_sta_process(struct ieee80
  	sta->rx_fragments++;
  	sta->rx_bytes += rx->skb->len;
  	sta->last_rssi = rx->u.rx.status->ssi;
+	sta->last_signal = rx->u.rx.status->signal;
+	sta->last_noise = rx->u.rx.status->noise;
+	sta->max_rssi = rx->u.rx.status->maxssi;

  	if (!(rx->fc & IEEE80211_FCTL_MOREFRAGS)) {
  		/* Change STA power saving mode only in the end of a frame



