From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] cls_flow: remove one dynamic array
Date: Wed, 14 Dec 2011 13:30:00 +0100
Message-ID: <1323865800.2334.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:38250 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756839Ab1LNMaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2011 07:30:06 -0500
Received: by wgbdr13 with SMTP id dr13so1734208wgb.1
        for <netdev@vger.kernel.org>; Wed, 14 Dec 2011 04:30:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Its better to use a predefined size for this small automatic variable.

Removes a sparse error as well :

net/sched/cls_flow.c:288:13: error: bad constant expression

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/sched/cls_flow.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 51ff194..1d8bd0d 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -285,7 +285,7 @@ static int flow_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 	int r;
 
 	list_for_each_entry(f, &head->filters, list) {
-		u32 keys[f->nkeys];
+		u32 keys[FLOW_KEY_MAX + 1];
 		struct flow_keys flow_keys;
 
 		if (!tcf_em_tree_match(skb, &f->ematches, NULL))
