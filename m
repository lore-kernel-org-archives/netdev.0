From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: [PATCH] net_sched: remove warning from qdisc_hash_add
Date: Tue, 15 Aug 2017 16:39:05 +0300
Message-ID: <150280434474.717808.1684163881218427525.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jiri Kosina <jkosina@suse.cz>, Eric Dumazet <edumazet@google.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forwardcorp1g.cmail.yandex.net ([87.250.241.190]:38089 "EHLO
        forwardcorp1g.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751089AbdHONqF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 09:46:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It was added in commit e57a784d8cae ("pkt_sched: set root qdisc
before change() in attach_default_qdiscs()") to hide duplicates
from "tc qdisc show" for incative deivices.

After 59cc1f61f ("net: sched: convert qdisc linked list to hashtable")
it triggered when classful qdisc is added to inactive device because
default qdiscs are added before switching root qdisc.

Anyway after commit ea3274695353 ("net: sched: avoid duplicates in
qdisc dump") duplicates are filtered right in dumper.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 net/sched/sch_api.c |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 18da45c0769c..2d2cf539668c 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -286,9 +286,6 @@ static struct Qdisc *qdisc_match_from_root(struct Qdisc *root, u32 handle)
 void qdisc_hash_add(struct Qdisc *q, bool invisible)
 {
 	if ((q->parent != TC_H_ROOT) && !(q->flags & TCQ_F_INGRESS)) {
-		struct Qdisc *root = qdisc_dev(q)->qdisc;
-
-		WARN_ON_ONCE(root == &noop_qdisc);
 		ASSERT_RTNL();
 		hash_add_rcu(qdisc_dev(q)->qdisc_hash, &q->hash, q->handle);
 		if (invisible)
