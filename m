From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next 5/7] tcp: skb_mstamp_after helper
Date: Fri, 16 Oct 2015 21:57:45 -0700
Message-ID: <1445057867-32257-6-git-send-email-ycheng@google.com>
References: <1445057867-32257-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33584 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751793AbbJQE6I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Oct 2015 00:58:08 -0400
Received: by pabrc13 with SMTP id rc13so138346447pab.0
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 21:58:08 -0700 (PDT)
In-Reply-To: <1445057867-32257-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

a helper to prepare the first main RACK patch.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/skbuff.h | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 4398411..24f4dfd 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -463,6 +463,15 @@ static inline u32 skb_mstamp_us_delta(const struct skb_mstamp *t1,
 	return delta_us;
 }
 
+static inline bool skb_mstamp_after(const struct skb_mstamp *t1,
+				    const struct skb_mstamp *t0)
+{
+	s32 diff = t1->stamp_jiffies - t0->stamp_jiffies;
+
+	if (!diff)
+		diff = t1->stamp_us - t0->stamp_us;
+	return diff > 0;
+}
 
 /** 
  *	struct sk_buff - socket buffer
-- 
2.6.0.rc2.230.g3dd15c0
