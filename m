From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 2/4] net/sched: cls_matchall: Dump skip flags and use them to reflect HW offload status
Date: Thu,  9 Feb 2017 16:18:06 +0200
Message-ID: <1486649888-2786-3-git-send-email-ogerlitz@mellanox.com>
References: <1486649888-2786-1-git-send-email-ogerlitz@mellanox.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        John Fastabend <john.r.fastabend@intel.com>,
        Amir Vadai <amirva@vadai.me>, netdev@vger.kernel.org,
        Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:52575 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752778AbdBIOSX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 09:18:23 -0500
In-Reply-To: <1486649888-2786-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently there is no way of querying whether a filter is offloaded
to HW or not, as the flags are not dumped to user-space, fix that.

Also, reuse the skip flags to show the insertion status by
setting the skip_hw flag in case the filter wasn't offloaded.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Acked-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_matchall.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/sched/cls_matchall.c b/net/sched/cls_matchall.c
index f2141cb..9dda12d 100644
--- a/net/sched/cls_matchall.c
+++ b/net/sched/cls_matchall.c
@@ -189,8 +189,10 @@ static int mall_change(struct net *net, struct sk_buff *in_skb,
 		if (err) {
 			if (tc_skip_sw(flags))
 				goto err_replace_hw_filter;
-			else
+			else {
+				new->flags |= TCA_CLS_FLAGS_SKIP_HW;
 				err = 0;
+			}
 		}
 	}
 
@@ -244,6 +246,8 @@ static int mall_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 	    nla_put_u32(skb, TCA_MATCHALL_CLASSID, head->res.classid))
 		goto nla_put_failure;
 
+	nla_put_u32(skb, TCA_MATCHALL_FLAGS, head->flags);
+
 	if (tcf_exts_dump(skb, &head->exts))
 		goto nla_put_failure;
 
-- 
2.3.7
