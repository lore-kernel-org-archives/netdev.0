From: Gilad Ben-Yossef <gilad@codefidence.com>
Subject: [PATCH v3 3/7] Add dst_feature to query route entry features
Date: Mon, 26 Oct 2009 10:06:29 +0200
Message-ID: <1256544393-12450-4-git-send-email-gilad@codefidence.com>
References: <1256544393-12450-1-git-send-email-gilad@codefidence.com>
Cc: ori@comsleep.com, Gilad Ben-Yossef <gilad@codefidence.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenbox.codefidence.com ([92.48.73.16]:47216 "EHLO
	xenbox.codefidence.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755226AbZJZIHA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 04:07:00 -0400
In-Reply-To: <1256544393-12450-1-git-send-email-gilad@codefidence.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding an accessor to existing  dst_entry feautres field and
refactor the only supported feature (allfrag) to use it.


Signed-off-by: Gilad Ben-Yossef <gilad@codefidence.com>
Sigend-off-by: Ori Finkelman <ori@comsleep.com>
Sigend-off-by: Yony Amit <yony@comsleep.com>

---
 include/net/dst.h |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 5a900dd..b562be3 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -111,6 +111,12 @@ dst_metric(const struct dst_entry *dst, int metric)
 	return dst->metrics[metric-1];
 }
 
+static inline u32
+dst_feature(const struct dst_entry *dst, u32 feature)
+{
+	return dst_metric(dst, RTAX_FEATURES) & feature;
+}
+
 static inline u32 dst_mtu(const struct dst_entry *dst)
 {
 	u32 mtu = dst_metric(dst, RTAX_MTU);
@@ -136,7 +142,7 @@ static inline void set_dst_metric_rtt(struct dst_entry *dst, int metric,
 static inline u32
 dst_allfrag(const struct dst_entry *dst)
 {
-	int ret = dst_metric(dst, RTAX_FEATURES) & RTAX_FEATURE_ALLFRAG;
+	int ret = dst_feature(dst,  RTAX_FEATURE_ALLFRAG);
 	/* Yes, _exactly_. This is paranoia. */
 	barrier();
 	return ret;
-- 
1.5.6.3

