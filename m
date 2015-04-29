From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 1/7] net: Add skb_get_hash_perturb
Date: Tue, 28 Apr 2015 21:27:35 -0700
Message-ID: <1430281661-2271966-2-git-send-email-tom@herbertland.com>
References: <1430281661-2271966-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jiri@resnulli.us>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:37697 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752650AbbD2E2F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 00:28:05 -0400
Received: from pps.filterd (m0004077 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t3T4RoSS007217
	for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 21:28:04 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1u2p8fr9ws-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 21:28:04 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.232.63) with ESMTP	id
 1fcda89aee2811e4afb00002c992ebde-377d02c0 for <netdev@vger.kernel.org>;	Tue,
 28 Apr 2015 21:28:02 -0700
In-Reply-To: <1430281661-2271966-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is used to get the skb->hash and then perturb it for a local use.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/skbuff.h | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 66e374d..b706889 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -17,6 +17,7 @@
 #include <linux/kernel.h>
 #include <linux/kmemcheck.h>
 #include <linux/compiler.h>
+#include <linux/jhash.h>
 #include <linux/time.h>
 #include <linux/bug.h>
 #include <linux/cache.h>
@@ -927,6 +928,20 @@ static inline __u32 skb_get_hash(struct sk_buff *skb)
 	return skb->hash;
 }
 
+static inline __u32 skb_get_hash_perturb(struct sk_buff *skb,
+					 u32 perturb)
+{
+	u32 hash = skb_get_hash(skb);
+
+	if (likely(hash)) {
+		hash = jhash_1word((__force __u32) hash, perturb);
+		if (unlikely(!hash))
+			hash = 1;
+	}
+
+	return hash;
+}
+
 static inline __u32 skb_get_hash_raw(const struct sk_buff *skb)
 {
 	return skb->hash;
-- 
1.8.1
