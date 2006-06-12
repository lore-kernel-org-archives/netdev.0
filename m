From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 4/5] d80211: add first_fragment flag to ieee80211_tx_control
Date: Mon, 12 Jun 2006 21:16:05 +0200 (CEST)
Message-ID: <20060612191605.73C4248390@silver.suse.cz>
References: <20060612211454.409884000.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Michael Buesch <mbuesch@freenet.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:3495 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S932097AbWFLTOw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2006 15:14:52 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060612211454.409884000.midnight@suse.cz>
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
 2 files changed, 4 insertions(+)

--- dscape.orig/include/net/d80211.h
+++ dscape/include/net/d80211.h
@@ -158,6 +158,8 @@ struct ieee80211_tx_control {
 	unsigned int rate_ctrl_probe:1;
 	unsigned int clear_dst_mask:1;
 	unsigned int requeue:1;
+	unsigned int first_fragment:1;	/* This is a first fragment of the
+					 * frame */
 	 /* following three flags are only used with Atheros Super A/G */
 	unsigned int compress:1;
 	unsigned int turbo_prime_notify:1; /* notify HostaAPd after frame
--- dscape.orig/net/d80211/ieee80211.c
+++ dscape/net/d80211/ieee80211.c
@@ -1120,6 +1120,7 @@ __ieee80211_tx_prepare(struct ieee80211_
 		u8 *pos = &skb->data[hdrlen + sizeof(rfc1042_header)];
 		tx->ethertype = (pos[0] << 8) | pos[1];
 	}
+	control->first_fragment = 1;
 
 }
 
@@ -1190,6 +1191,7 @@ static int __ieee80211_tx(struct ieee802
 		control->use_rts_cts = 0;
 		control->use_cts_protect = 0;
 		control->clear_dst_mask = 0;
+		control->first_fragment = 0;
 		for (i = 0; i < tx->u.tx.num_extra_frag; i++) {
 			if (!tx->u.tx.extra_frag[i])
 				continue;
