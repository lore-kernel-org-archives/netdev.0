From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH iproute2 net-next] bonding: export 3ad actor and partner port state
Date: Tue, 16 Jun 2015 12:26:57 +0300
Message-ID: <1434446817-1224-1-git-send-email-razor@blackwall.org>
Cc: stephen@networkplumber.org,
	Nikolay Aleksandrov <razor@blackwall.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:34592 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932347AbbFPJ1F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2015 05:27:05 -0400
Received: by wgv5 with SMTP id 5so7724746wgv.1
        for <netdev@vger.kernel.org>; Tue, 16 Jun 2015 02:27:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support to retrieve the new bond slave attributes:
IFLA_BOND_SLAVE_AD_ACTOR_OPER_PORT_STATE
IFLA_BOND_SLAVE_AD_PARTNER_OPER_PORT_STATE
which are read-only.
This patch also adds the linux/if_link.h definitions.

Signed-off-by: Nikolay Aleksandrov <razor@blackwall.org>
---
 include/linux/if_link.h | 2 ++
 ip/iplink_bond_slave.c  | 8 ++++++++
 2 files changed, 10 insertions(+)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 7720ad34c6b3..63555875c0c5 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -452,6 +452,8 @@ enum {
 	IFLA_BOND_SLAVE_PERM_HWADDR,
 	IFLA_BOND_SLAVE_QUEUE_ID,
 	IFLA_BOND_SLAVE_AD_AGGREGATOR_ID,
+	IFLA_BOND_SLAVE_AD_ACTOR_OPER_PORT_STATE,
+	IFLA_BOND_SLAVE_AD_PARTNER_OPER_PORT_STATE,
 	__IFLA_BOND_SLAVE_MAX,
 };
 
diff --git a/ip/iplink_bond_slave.c b/ip/iplink_bond_slave.c
index aacba14aef9c..33bea9132b78 100644
--- a/ip/iplink_bond_slave.c
+++ b/ip/iplink_bond_slave.c
@@ -78,6 +78,14 @@ static void bond_slave_print_opt(struct link_util *lu, FILE *f, struct rtattr *t
 	if (tb[IFLA_BOND_SLAVE_AD_AGGREGATOR_ID])
 		fprintf(f, "ad_aggregator_id %d ",
 			rta_getattr_u16(tb[IFLA_BOND_SLAVE_AD_AGGREGATOR_ID]));
+
+	if (tb[IFLA_BOND_SLAVE_AD_ACTOR_OPER_PORT_STATE])
+		fprintf(f, "ad_actor_oper_port_state %d\n",
+			rta_getattr_u8(tb[IFLA_BOND_SLAVE_AD_ACTOR_OPER_PORT_STATE]));
+
+	if (tb[IFLA_BOND_SLAVE_AD_PARTNER_OPER_PORT_STATE])
+		fprintf(f, "ad_partner_oper_port_state %d\n",
+			rta_getattr_u16(tb[IFLA_BOND_SLAVE_AD_PARTNER_OPER_PORT_STATE]));
 }
 
 static int bond_slave_parse_opt(struct link_util *lu, int argc, char **argv,
-- 
2.4.3
