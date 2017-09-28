From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next] net: ipv4: remove fib_info arg to fib_check_nh
Date: Wed, 27 Sep 2017 20:41:59 -0700
Message-ID: <1506570119-17088-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33209 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752343AbdI1DmG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 23:42:06 -0400
Received: by mail-pf0-f195.google.com with SMTP id h4so314097pfk.0
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 20:42:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fib_check_nh does not use the fib_info arg; remove t.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 net/ipv4/fib_semantics.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 57a5d48acee8..79989124607e 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -774,8 +774,8 @@ bool fib_metrics_match(struct fib_config *cfg, struct fib_info *fi)
  *					|
  *					|-> {local prefix} (terminal node)
  */
-static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
-			struct fib_nh *nh, struct netlink_ext_ack *extack)
+static int fib_check_nh(struct fib_config *cfg, struct fib_nh *nh,
+			struct netlink_ext_ack *extack)
 {
 	int err = 0;
 	struct net *net;
@@ -1258,7 +1258,7 @@ struct fib_info *fib_create_info(struct fib_config *cfg,
 		int linkdown = 0;
 
 		change_nexthops(fi) {
-			err = fib_check_nh(cfg, fi, nexthop_nh, extack);
+			err = fib_check_nh(cfg, nexthop_nh, extack);
 			if (err != 0)
 				goto failure;
 			if (nexthop_nh->nh_flags & RTNH_F_LINKDOWN)
-- 
2.1.4
