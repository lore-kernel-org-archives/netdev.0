From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 05/10] net: sched: move TC_H_MAJ macro call into tcf_auto_prio
Date: Thu, 27 Apr 2017 13:12:15 +0200
Message-ID: <1493291540-2119-6-git-send-email-jiri@resnulli.us>
References: <1493291540-2119-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        dsa@cumulusnetworks.com, edumazet@google.com,
        stephen@networkplumber.org, daniel@iogearbox.net,
        alexander.h.duyck@intel.com, mlxsw@mellanox.com,
        simon.horman@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36611 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936047AbdD0LMb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 07:12:31 -0400
Received: by mail-wm0-f66.google.com with SMTP id u65so3797216wmu.3
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 04:12:30 -0700 (PDT)
In-Reply-To: <1493291540-2119-1-git-send-email-jiri@resnulli.us>
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
2.7.4
