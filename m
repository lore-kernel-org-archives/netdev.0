From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V3 2/7] net/sched: cls_matchall: Dump the classifier flags
Date: Wed, 15 Feb 2017 10:52:32 +0200
Message-ID: <1487148757-24809-3-git-send-email-ogerlitz@mellanox.com>
References: <1487148757-24809-1-git-send-email-ogerlitz@mellanox.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>,
        John Fastabend <john.r.fastabend@intel.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Roi Dayan <roid@mellanox.com>, Jiri Pirko <jiri@mellanox.com>,
        netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:36612 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751307AbdBOIwp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 03:52:45 -0500
In-Reply-To: <1487148757-24809-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The classifier flags are not dumped to user-space, do that.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Acked-by: Jiri Pirko <jiri@mellanox.com>
Acked-by: Yotam Gigi <yotamg@mellanox.com>
---
 net/sched/cls_matchall.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/sched/cls_matchall.c b/net/sched/cls_matchall.c
index f2141cb..35ef1c1 100644
--- a/net/sched/cls_matchall.c
+++ b/net/sched/cls_matchall.c
@@ -244,6 +244,9 @@ static int mall_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 	    nla_put_u32(skb, TCA_MATCHALL_CLASSID, head->res.classid))
 		goto nla_put_failure;
 
+	if (head->flags && nla_put_u32(skb, TCA_MATCHALL_FLAGS, head->flags))
+		goto nla_put_failure;
+
 	if (tcf_exts_dump(skb, &head->exts))
 		goto nla_put_failure;
 
-- 
2.3.7
