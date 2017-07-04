From: "McCabe, Robert J" <Robert.McCabe@rockwellcollins.com>
Subject: [PATCH 1/1] net sched: Added the TC_LINKLAYER_CUSTOM linklayer type
Date: Mon,  3 Jul 2017 19:14:25 -0500
Message-ID: <20170704001426.9268-1-Robert.McCabe@rockwellcollins.com>
Cc: robert.mccabe@rockwellcollins.com,
        "McCabe, Robert J" <Robert.McCabe@rockwellcollins.com>,
        McCabe@rockwellcollins.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpimr.rockwellcollins.com ([205.175.225.240]:3161 "EHLO
        secvs01.rockwellcollins.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750793AbdGDAOp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2017 20:14:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is to support user-space modification of the qdisc stab.

Signed-off-by: McCabe, Robert J <Robert.McCabe@rockwellcollins.com>
---
 include/uapi/linux/pkt_sched.h | 1 +
 net/sched/sch_api.c            | 2 ++
 2 files changed, 3 insertions(+)

diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sched.h
index 099bf55..289bb81 100644
--- a/include/uapi/linux/pkt_sched.h
+++ b/include/uapi/linux/pkt_sched.h
@@ -82,6 +82,7 @@ enum tc_link_layer {
 	TC_LINKLAYER_UNAWARE, /* Indicate unaware old iproute2 util */
 	TC_LINKLAYER_ETHERNET,
 	TC_LINKLAYER_ATM,
+	TC_LINKLAYER_CUSTOM,
 };
 #define TC_LINKLAYER_MASK 0x0F /* limit use to lower 4 bits */
 
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 43b94c7..174a925 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -533,6 +533,8 @@ static int qdisc_dump_stab(struct sk_buff *skb, struct qdisc_size_table *stab)
 		goto nla_put_failure;
 	if (nla_put(skb, TCA_STAB_BASE, sizeof(stab->szopts), &stab->szopts))
 		goto nla_put_failure;
+	if (nla_put(skb, TCA_STAB_DATA, sizeof(stab->szopts)*sizeof(u16), &stab->data))
+		goto nla_put_failure;
 	nla_nest_end(skb, nest);
 
 	return skb->len;
-- 
2.7.4
