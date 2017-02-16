From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V4 1/7] net/sched: cls_flower: Properly handle classifier flags dumping
Date: Thu, 16 Feb 2017 10:31:10 +0200
Message-ID: <1487233876-28576-2-git-send-email-ogerlitz@mellanox.com>
References: <1487233876-28576-1-git-send-email-ogerlitz@mellanox.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, Roi Dayan <roid@mellanox.com>,
        netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:45005 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752983AbdBPIbi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 03:31:38 -0500
In-Reply-To: <1487233876-28576-1-git-send-email-ogerlitz@mellanox.com>
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
2.5.5
