From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 4/21] d80211: use kzalloc()
Date: Wed, 23 Aug 2006 21:24:12 +0200 (CEST)
Message-ID: <20060823192412.DB0E0483A4@silver.suse.cz>
References: <20060823212316.333159079.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:28112 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S965126AbWHWTYM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 15:24:12 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060823212316.333159079.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes@sipsolutions.net>

This changes d80211 to use kzalloc() where applicable.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c    |    7 ++-----
 net/d80211/rate_control.c |   10 ++--------
 2 files changed, 4 insertions(+), 13 deletions(-)

ce05baacb2a48dfc5f917c63fcb52537991bbb1a
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index ac0b706..04c791d 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
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
@@ -4714,11 +4712,10 @@ int ieee80211_rate_control_register(stru
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
diff --git a/net/d80211/rate_control.c b/net/d80211/rate_control.c
index 4f1ffbd..ff383ab 100644
--- a/net/d80211/rate_control.c
+++ b/net/d80211/rate_control.c
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
1.3.0

