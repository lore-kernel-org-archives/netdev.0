From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net_sched: sch_mqprio: dont leak kernel memory
Date: Wed, 26 Jan 2011 18:21:57 +0100
Message-ID: <1296062517.2899.86.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	John Fastabend <john.r.fastabend@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:43134 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753701Ab1AZRWD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jan 2011 12:22:03 -0500
Received: by wwa36 with SMTP id 36so1205447wwa.1
        for <netdev@vger.kernel.org>; Wed, 26 Jan 2011 09:22:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mqprio_dump() should make sure all fields of struct tc_mqprio_qopt are
initialized.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: John Fastabend <john.r.fastabend@intel.com>
---
 net/sched/sch_mqprio.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
index fbc6f53..effd4ee 100644
--- a/net/sched/sch_mqprio.c
+++ b/net/sched/sch_mqprio.c
@@ -215,7 +215,7 @@ static int mqprio_dump(struct Qdisc *sch, struct sk_buff *skb)
 	struct net_device *dev = qdisc_dev(sch);
 	struct mqprio_sched *priv = qdisc_priv(sch);
 	unsigned char *b = skb_tail_pointer(skb);
-	struct tc_mqprio_qopt opt;
+	struct tc_mqprio_qopt opt = { 0 };
 	struct Qdisc *qdisc;
 	unsigned int i;
 


