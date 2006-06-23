From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 4/5] d80211: add first_fragment flag to ieee80211_tx_control
Date: Fri, 23 Jun 2006 15:01:21 +0200 (CEST)
Message-ID: <20060623130121.C4314483AF@silver.suse.cz>
References: <20060623150047.368594000.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:12423 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S964802AbWFWM77 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2006 08:59:59 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060623150047.368594000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If a driver needs to find out if the fragment it is supposed to pass to the
hardware is the first fragment, the only way to do this is to check if
a Fragment Number part of seq_ctrl field in the frame header equals to 0.
Let's make it easier.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 include/net/d80211.h   |    2 ++
 net/d80211/ieee80211.c |    2 ++
 2 files changed, 4 insertions(+), 0 deletions(-)

e360f2605cbb71f359de21a59eff1bcbab150e7f
diff --git a/include/net/d80211.h b/include/net/d80211.h
index 141f776..6ae4325 100644
--- a/include/net/d80211.h
+++ b/include/net/d80211.h
@@ -158,6 +158,8 @@ struct ieee80211_tx_control {
 	unsigned int rate_ctrl_probe:1;
 	unsigned int clear_dst_mask:1;
 	unsigned int requeue:1;
+	unsigned int first_fragment:1;	/* This is a first fragment of the
+					 * frame */
 	 /* following three flags are only used with Atheros Super A/G */
 	unsigned int compress:1;
 	unsigned int turbo_prime_notify:1; /* notify HostaAPd after frame
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 0f01311..9fc3518 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -1120,6 +1120,7 @@ __ieee80211_tx_prepare(struct ieee80211_
 		u8 *pos = &skb->data[hdrlen + sizeof(rfc1042_header)];
 		tx->ethertype = (pos[0] << 8) | pos[1];
 	}
+	control->first_fragment = 1;
 
 }
 
@@ -1190,6 +1191,7 @@ #endif /* IEEE80211_LEDS */
 		control->use_rts_cts = 0;
 		control->use_cts_protect = 0;
 		control->clear_dst_mask = 0;
+		control->first_fragment = 0;
 		for (i = 0; i < tx->u.tx.num_extra_frag; i++) {
 			if (!tx->u.tx.extra_frag[i])
 				continue;
-- 
1.3.0

