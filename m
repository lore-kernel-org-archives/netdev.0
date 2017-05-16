From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 05/10] net: sched: move TC_H_MAJ macro call into tcf_auto_prio
Date: Tue, 16 May 2017 19:27:57 +0200
Message-ID: <20170516172802.1317-6-jiri@resnulli.us>
References: <20170516172802.1317-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        dsa@cumulusnetworks.com, edumazet@google.com,
        stephen@networkplumber.org, daniel@iogearbox.net,
        alexander.h.duyck@intel.com, simon.horman@netronome.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35734 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751716AbdEPR2M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 13:28:12 -0400
Received: by mail-wm0-f65.google.com with SMTP id v4so39818198wmb.2
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 10:28:12 -0700 (PDT)
In-Reply-To: <20170516172802.1317-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Call the helper from the function rather than to always adjust the
return value of the function.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_api.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 0e49e6e..72624fa 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -125,7 +125,7 @@ static inline u32 tcf_auto_prio(struct tcf_proto *tp)
 	if (tp)
 		first = tp->prio - 1;
 
-	return first;
+	return TC_H_MAJ(first);
 }
 
 static struct tcf_proto *tcf_proto_create(const char *kind, u32 protocol,
@@ -405,7 +405,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
 		}
 
 		if (prio_allocate)
-			prio = TC_H_MAJ(tcf_auto_prio(rtnl_dereference(*back)));
+			prio = tcf_auto_prio(rtnl_dereference(*back));
 
 		tp = tcf_proto_create(nla_data(tca[TCA_KIND]),
 				      protocol, prio, parent, q, block);
-- 
2.9.3
