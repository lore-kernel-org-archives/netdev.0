From: Roi Dayan <roid@mellanox.com>
Subject: [PATCH iproute2] tc: flower: Fix flower output for src and dst ports
Date: Sun, 15 Jan 2017 16:23:49 +0200
Message-ID: <1484490229-19712-1-git-send-email-roid@mellanox.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>,
        Roi Dayan <roid@mellanox.com>, Paul Blakey <paulb@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:52424 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750831AbdAOOYJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Jan 2017 09:24:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fix a missing use case after the introduction of enum flower_endpoint.

Fixes: 6910d65661a3 ("tc: flower: introduce enum flower_endpoint")
Signed-off-by: Roi Dayan <roid@mellanox.com>
Signed-off-by: Paul Blakey <paulb@mellanox.com>
---
 tc/f_flower.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tc/f_flower.c b/tc/f_flower.c
index 71e9515..1dbc532 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -744,10 +744,10 @@ static int flower_print_opt(struct filter_util *qu, FILE *f,
 			     tb[TCA_FLOWER_KEY_IPV6_SRC],
 			     tb[TCA_FLOWER_KEY_IPV6_SRC_MASK]);
 
-	nl_type = flower_port_attr_type(ip_proto, false);
+	nl_type = flower_port_attr_type(ip_proto, FLOWER_ENDPOINT_DST);
 	if (nl_type >= 0)
 		flower_print_port(f, "dst_port", tb[nl_type]);
-	nl_type = flower_port_attr_type(ip_proto, true);
+	nl_type = flower_port_attr_type(ip_proto, FLOWER_ENDPOINT_SRC);
 	if (nl_type >= 0)
 		flower_print_port(f, "src_port", tb[nl_type]);
 
-- 
1.7.1
