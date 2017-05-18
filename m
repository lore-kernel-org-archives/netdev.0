From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net: sched: fix a use-after-free error on chain on the error exit path
Date: Thu, 18 May 2017 15:07:02 +0100
Message-ID: <20170518140702.6072-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Set chain to null after the call to tcf_chain_destroy so that we don't
call tcf_chain_put on the error exit path, thus avoiding a use-after-free
error.

Detected by CoverityScan, CID#1436357 ("Use after free")

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/sched/cls_api.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 4020b8d932a1..82ebdc3fcb2e 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -511,6 +511,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
 	if (n->nlmsg_type == RTM_DELTFILTER && prio == 0) {
 		tfilter_notify_chain(net, skb, n, chain, RTM_DELTFILTER);
 		tcf_chain_destroy(chain);
+		chain = NULL;
 		err = 0;
 		goto errout;
 	}
-- 
2.11.0
