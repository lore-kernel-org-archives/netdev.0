From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [net-next PATCH 1/1] sched,cls_flower: set key address type when present
Date: Sun, 10 Jan 2016 11:47:01 -0500
Message-ID: <1452444421-3939-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net, jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:36546 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756135AbcAJQrU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 11:47:20 -0500
Received: by mail-io0-f195.google.com with SMTP id q21so24323166iod.3
        for <netdev@vger.kernel.org>; Sun, 10 Jan 2016 08:47:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

only when user space passes the addresses should we consider their
presence

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
Acked-by: Jiri Pirko <jiri@resnulli.us>
---
 net/sched/cls_flower.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 5769294..95b0212 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -252,23 +252,28 @@ static int fl_set_key(struct net *net, struct nlattr **tb,
 	fl_set_key_val(tb, key->eth.src, TCA_FLOWER_KEY_ETH_SRC,
 		       mask->eth.src, TCA_FLOWER_KEY_ETH_SRC_MASK,
 		       sizeof(key->eth.src));
+
 	fl_set_key_val(tb, &key->basic.n_proto, TCA_FLOWER_KEY_ETH_TYPE,
 		       &mask->basic.n_proto, TCA_FLOWER_UNSPEC,
 		       sizeof(key->basic.n_proto));
+
 	if (key->basic.n_proto == htons(ETH_P_IP) ||
 	    key->basic.n_proto == htons(ETH_P_IPV6)) {
 		fl_set_key_val(tb, &key->basic.ip_proto, TCA_FLOWER_KEY_IP_PROTO,
 			       &mask->basic.ip_proto, TCA_FLOWER_UNSPEC,
 			       sizeof(key->basic.ip_proto));
 	}
-	if (key->control.addr_type == FLOW_DISSECTOR_KEY_IPV4_ADDRS) {
+
+	if (tb[TCA_FLOWER_KEY_IPV4_SRC] || tb[TCA_FLOWER_KEY_IPV4_DST]) {
+		key->control.addr_type = FLOW_DISSECTOR_KEY_IPV4_ADDRS;
 		fl_set_key_val(tb, &key->ipv4.src, TCA_FLOWER_KEY_IPV4_SRC,
 			       &mask->ipv4.src, TCA_FLOWER_KEY_IPV4_SRC_MASK,
 			       sizeof(key->ipv4.src));
 		fl_set_key_val(tb, &key->ipv4.dst, TCA_FLOWER_KEY_IPV4_DST,
 			       &mask->ipv4.dst, TCA_FLOWER_KEY_IPV4_DST_MASK,
 			       sizeof(key->ipv4.dst));
-	} else if (key->control.addr_type == FLOW_DISSECTOR_KEY_IPV6_ADDRS) {
+	} else if (tb[TCA_FLOWER_KEY_IPV6_SRC] || tb[TCA_FLOWER_KEY_IPV6_DST]) {
+		key->control.addr_type = FLOW_DISSECTOR_KEY_IPV6_ADDRS;
 		fl_set_key_val(tb, &key->ipv6.src, TCA_FLOWER_KEY_IPV6_SRC,
 			       &mask->ipv6.src, TCA_FLOWER_KEY_IPV6_SRC_MASK,
 			       sizeof(key->ipv6.src));
@@ -276,6 +281,7 @@ static int fl_set_key(struct net *net, struct nlattr **tb,
 			       &mask->ipv6.dst, TCA_FLOWER_KEY_IPV6_DST_MASK,
 			       sizeof(key->ipv6.dst));
 	}
+
 	if (key->basic.ip_proto == IPPROTO_TCP) {
 		fl_set_key_val(tb, &key->tp.src, TCA_FLOWER_KEY_TCP_SRC,
 			       &mask->tp.src, TCA_FLOWER_UNSPEC,
-- 
1.9.1
