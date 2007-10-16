From: jamal <hadi@cyberus.ca>
Subject: [PATCH 1/3] [NET_CLS_ACT] Introduce skb_act_clone
Date: Tue, 16 Oct 2007 08:29:57 -0400
Message-ID: <1192537797.4480.77.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-wqFlyfTe/lqYiyteTGZF"
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.178]:4320 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757601AbXJPMaR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 08:30:17 -0400
Received: by wa-out-1112.google.com with SMTP id v27so2361907wah
        for <netdev@vger.kernel.org>; Tue, 16 Oct 2007 05:30:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-wqFlyfTe/lqYiyteTGZF
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


cheers,
jamal

--=-wqFlyfTe/lqYiyteTGZF
Content-Disposition: attachment; filename=0001-NET_CLS_ACT-Introduce-skb_act_clone
Content-Type: text/plain; name=0001-NET_CLS_ACT-Introduce-skb_act_clone; charset=us-ascii
Content-Transfer-Encoding: 7bit

[NET_CLS_ACT] Introduce skb_act_clone
Reworked skb_clone looks uglier with the single ifdef CONFIG_NET_CLS_ACT
This patch introduces skb_act_clone which will replace skb_clone
in tc actions

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
---
 include/net/sch_generic.h |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index a02ec9e..c926551 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -316,4 +316,19 @@ static inline u32 qdisc_l2t(struct qdisc_rate_table* rtab, unsigned int pktlen)
 	return rtab->data[slot];
 }
 
+#ifdef CONFIG_NET_CLS_ACT
+static inline struct sk_buff *skb_act_clone(struct sk_buff *skb, gfp_t gfp_mask)
+{
+	struct sk_buff *n = skb_clone(skb, gfp_mask);
+
+	if (n) {
+		n->tc_verd = SET_TC_VERD(n->tc_verd, 0);
+		n->tc_verd = CLR_TC_OK2MUNGE(n->tc_verd);
+		n->tc_verd = CLR_TC_MUNGED(n->tc_verd);
+		n->iif = skb->iif;
+	}
+	return n;
+}
+#endif
+
 #endif
-- 
1.4.4.1.gaed4


--=-wqFlyfTe/lqYiyteTGZF--

