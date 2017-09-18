From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net_sched: use explicit size of struct tcmsg, remove need to declare tcm
Date: Mon, 18 Sep 2017 12:40:38 +0100
Message-ID: <20170918114038.29741-1-colin.king@canonical.com>
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

Pointer tcm is being initialized and is never read, it is only being used
to determine the size of struct tcmsg.  Clean this up by removing
variable tcm and explicitly using the sizeof struct tcmsg rather than *tcm.
Cleans up clang warning:

warning: Value stored to 'tcm' during its initialization is never read

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/sched/sch_api.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index c6deb74e3d2f..aa82116ed10c 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1500,7 +1500,6 @@ static int tc_dump_qdisc(struct sk_buff *skb, struct netlink_callback *cb)
 	int s_idx, s_q_idx;
 	struct net_device *dev;
 	const struct nlmsghdr *nlh = cb->nlh;
-	struct tcmsg *tcm = nlmsg_data(nlh);
 	struct nlattr *tca[TCA_MAX + 1];
 	int err;
 
@@ -1510,7 +1509,7 @@ static int tc_dump_qdisc(struct sk_buff *skb, struct netlink_callback *cb)
 	idx = 0;
 	ASSERT_RTNL();
 
-	err = nlmsg_parse(nlh, sizeof(*tcm), tca, TCA_MAX, NULL, NULL);
+	err = nlmsg_parse(nlh, sizeof(struct tcmsg), tca, TCA_MAX, NULL, NULL);
 	if (err < 0)
 		return err;
 
-- 
2.14.1
