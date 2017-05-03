From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net/sched: remove redundant null check on head
Date: Wed,  3 May 2017 14:50:40 +0100
Message-ID: <20170503135040.32023-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org,
        "David S . Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

head is previously null checked and so the 2nd null check on head
is redundant and therefore can be removed.

Detected by CoverityScan, CID#1399505 ("Logically dead code")

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/sched/cls_matchall.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/sched/cls_matchall.c b/net/sched/cls_matchall.c
index 2efb36c08f2a..dee469fed967 100644
--- a/net/sched/cls_matchall.c
+++ b/net/sched/cls_matchall.c
@@ -203,8 +203,7 @@ static int mall_change(struct net *net, struct sk_buff *in_skb,
 
 	*arg = (unsigned long) head;
 	rcu_assign_pointer(tp->root, new);
-	if (head)
-		call_rcu(&head->rcu, mall_destroy_rcu);
+	call_rcu(&head->rcu, mall_destroy_rcu);
 	return 0;
 
 err_replace_hw_filter:
-- 
2.11.0
