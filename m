From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V3 1/7] net/sched: cls_flower: Properly handle classifier flags dumping
Date: Wed, 15 Feb 2017 10:52:31 +0200
Message-ID: <1487148757-24809-2-git-send-email-ogerlitz@mellanox.com>
References: <1487148757-24809-1-git-send-email-ogerlitz@mellanox.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>,
        John Fastabend <john.r.fastabend@intel.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Roi Dayan <roid@mellanox.com>, Jiri Pirko <jiri@mellanox.com>,
        netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:36613 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751305AbdBOIwp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 03:52:45 -0500
In-Reply-To: <1487148757-24809-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dump the classifier flags only if non zero and make sure to check
the return status of the handler that puts them into the netlink msg.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 net/sched/cls_flower.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 0826c8e..850d982 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -1229,7 +1229,8 @@ static int fl_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 	if (fl_dump_key_flags(skb, key->control.flags, mask->control.flags))
 		goto nla_put_failure;
 
-	nla_put_u32(skb, TCA_FLOWER_FLAGS, f->flags);
+	if (f->flags && nla_put_u32(skb, TCA_FLOWER_FLAGS, f->flags))
+		goto nla_put_failure;
 
 	if (tcf_exts_dump(skb, &f->exts))
 		goto nla_put_failure;
-- 
2.3.7
