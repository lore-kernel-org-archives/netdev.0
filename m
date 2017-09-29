From: Colin King <colin.king@canonical.com>
Subject: [PATCH][net-next] net_sched: remove redundant assignment to ret
Date: Fri, 29 Sep 2017 15:01:16 +0100
Message-ID: <20170929140116.8642-1-colin.king@canonical.com>
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

The assignment of -EINVAL to variable ret is redundant as it
is being overwritten on the following error exit paths or
to the return value from the following call to basic_set_parms.
Fix this up by removing it. Cleans up clang warning message:

net/sched/cls_basic.c:185:2: warning: Value stored to 'err' is never read

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/sched/cls_basic.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index cfeb6f158566..700b345b07f9 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -182,7 +182,6 @@ static int basic_change(struct net *net, struct sk_buff *in_skb,
 	if (err < 0)
 		goto errout;
 
-	err = -EINVAL;
 	if (handle) {
 		fnew->handle = handle;
 		if (!fold) {
-- 
2.14.1
