From: Paul Blakey <paulb@mellanox.com>
Subject: [PATCH net 1/2] net/sched: cls_flower: Use mask for addr_type
Date: Wed, 14 Dec 2016 19:00:57 +0200
Message-ID: <1481734858-37474-2-git-send-email-paulb@mellanox.com>
References: <1481734858-37474-1-git-send-email-paulb@mellanox.com>
Cc: Jiri Pirko <jiri@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Shahar Klein <shahark@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Paul Blakey <paulb@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44452 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753757AbcLNRID (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2016 12:08:03 -0500
In-Reply-To: <1481734858-37474-1-git-send-email-paulb@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When addr_type is set, mask should also be set.

Fixes: 66530bdf85eb ('sched,cls_flower: set key address type when present')
Fixes: bc3103f1ed40 ('net/sched: cls_flower: Classify packet in ip tunnels')
Signed-off-by: Paul Blakey <paulb@mellanox.com>
Reviewed-by: Roi Dayan <roid@mellanox.com>
Acked-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_flower.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index e040c51..9758f5a 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -509,6 +509,7 @@ static int fl_set_key(struct net *net, struct nlattr **tb,
 
 	if (tb[TCA_FLOWER_KEY_IPV4_SRC] || tb[TCA_FLOWER_KEY_IPV4_DST]) {
 		key->control.addr_type = FLOW_DISSECTOR_KEY_IPV4_ADDRS;
+		mask->control.addr_type = ~0;
 		fl_set_key_val(tb, &key->ipv4.src, TCA_FLOWER_KEY_IPV4_SRC,
 			       &mask->ipv4.src, TCA_FLOWER_KEY_IPV4_SRC_MASK,
 			       sizeof(key->ipv4.src));
@@ -517,6 +518,7 @@ static int fl_set_key(struct net *net, struct nlattr **tb,
 			       sizeof(key->ipv4.dst));
 	} else if (tb[TCA_FLOWER_KEY_IPV6_SRC] || tb[TCA_FLOWER_KEY_IPV6_DST]) {
 		key->control.addr_type = FLOW_DISSECTOR_KEY_IPV6_ADDRS;
+		mask->control.addr_type = ~0;
 		fl_set_key_val(tb, &key->ipv6.src, TCA_FLOWER_KEY_IPV6_SRC,
 			       &mask->ipv6.src, TCA_FLOWER_KEY_IPV6_SRC_MASK,
 			       sizeof(key->ipv6.src));
@@ -571,6 +573,7 @@ static int fl_set_key(struct net *net, struct nlattr **tb,
 	if (tb[TCA_FLOWER_KEY_ENC_IPV4_SRC] ||
 	    tb[TCA_FLOWER_KEY_ENC_IPV4_DST]) {
 		key->enc_control.addr_type = FLOW_DISSECTOR_KEY_IPV4_ADDRS;
+		mask->enc_control.addr_type = ~0;
 		fl_set_key_val(tb, &key->enc_ipv4.src,
 			       TCA_FLOWER_KEY_ENC_IPV4_SRC,
 			       &mask->enc_ipv4.src,
@@ -586,6 +589,7 @@ static int fl_set_key(struct net *net, struct nlattr **tb,
 	if (tb[TCA_FLOWER_KEY_ENC_IPV6_SRC] ||
 	    tb[TCA_FLOWER_KEY_ENC_IPV6_DST]) {
 		key->enc_control.addr_type = FLOW_DISSECTOR_KEY_IPV6_ADDRS;
+		mask->enc_control.addr_type = ~0;
 		fl_set_key_val(tb, &key->enc_ipv6.src,
 			       TCA_FLOWER_KEY_ENC_IPV6_SRC,
 			       &mask->enc_ipv6.src,
-- 
1.8.3.1
