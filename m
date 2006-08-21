From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 04/18] d80211:  use kzalloc()
Date: Mon, 21 Aug 2006 09:41:11 +0200
Message-ID: <20060821075159.394677751@sipsolutions.net>
References: <20060821074107.648561364@sipsolutions.net>
Mime-Version: 1.0
Cc: Jouni Malinen <jkm@devicescape.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:61376 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1030312AbWHUICS
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 04:02:18 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=d80211-kzalloc.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This changes d80211 to use kzalloc() where applicable.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

--- wireless-dev.orig/net/d80211/ieee80211.c	2006-08-20 14:56:17.428192788 +0200
+++ wireless-dev/net/d80211/ieee80211.c	2006-08-20 14:56:18.438192788 +0200
@@ -454,11 +454,9 @@ ieee80211_tx_h_fragment(struct ieee80211
 	per_fragm = frag_threshold - hdrlen - 4 /* FCS */;
 	num_fragm = (payload_len + per_fragm - 1) / per_fragm;
 
-	frags = (struct sk_buff **)
-		kmalloc(num_fragm * sizeof(struct sk_buff *), GFP_ATOMIC);
+	frags = kzalloc(num_fragm * sizeof(struct sk_buff *), GFP_ATOMIC);
 	if (!frags)
 		goto fail;
-	memset(frags, 0, num_fragm * sizeof(struct sk_buff *));
 
 	hdr->frame_control |= cpu_to_le16(IEEE80211_FCTL_MOREFRAGS);
 	pos = first->data + hdrlen + per_fragm;
@@ -4696,11 +4694,10 @@ int ieee80211_rate_control_register(stru
 {
 	struct rate_control_algs *alg;
 
-	alg = kmalloc(sizeof(*alg), GFP_KERNEL);
+	alg = kzalloc(sizeof(*alg), GFP_KERNEL);
 	if (!alg)
 		return -1;
 
-	memset(alg, 0, sizeof(*alg));
 	alg->next = ieee80211_rate_ctrl_algs;
 	alg->ops = ops;
 	ieee80211_rate_ctrl_algs = alg;
--- wireless-dev.orig/net/d80211/rate_control.c	2006-08-20 14:56:17.418192788 +0200
+++ wireless-dev/net/d80211/rate_control.c	2006-08-20 14:56:18.438192788 +0200
@@ -287,11 +287,8 @@ static void * rate_control_simple_alloc(
 {
 	struct global_rate_control *rctrl;
 
-	rctrl = kmalloc(sizeof(*rctrl), GFP_ATOMIC);
-	if (!rctrl)
-		return NULL;
+	rctrl = kzalloc(sizeof(*rctrl), GFP_ATOMIC);
 
-	memset(rctrl, 0, sizeof(*rctrl));
 	return rctrl;
 }
 
@@ -312,11 +309,8 @@ static void * rate_control_simple_alloc_
 {
 	struct sta_rate_control *rctrl;
 
-	rctrl = kmalloc(sizeof(*rctrl), GFP_ATOMIC);
-	if (!rctrl)
-		return NULL;
+	rctrl = kzalloc(sizeof(*rctrl), GFP_ATOMIC);
 
-	memset(rctrl, 0, sizeof(*rctrl));
 	return rctrl;
 }
 

--
