From: sfeldma@gmail.com
Subject: [PATCH net-next] bridge: fix netlink max attr size
Date: Wed, 19 Aug 2015 11:29:35 -0700
Message-ID: <1440008975-41080-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:35087 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751650AbbHSS0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 14:26:53 -0400
Received: by pdob1 with SMTP id b1so4282213pdo.2
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 11:26:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

.maxtype should match .policy.  Probably just been getting lucky here
because IFLA_BRPORT_MAX > IFLA_BR_MAX.

Fixes: 13323516 ("bridge: implement rtnl_link_ops->changelink")
Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 net/bridge/br_netlink.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 01401ea..d2c4d66 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -849,7 +849,7 @@ struct rtnl_link_ops br_link_ops __read_mostly = {
 	.kind			= "bridge",
 	.priv_size		= sizeof(struct net_bridge),
 	.setup			= br_dev_setup,
-	.maxtype		= IFLA_BRPORT_MAX,
+	.maxtype		= IFLA_BR_MAX,
 	.policy			= br_policy,
 	.validate		= br_validate,
 	.newlink		= br_dev_newlink,
-- 
1.7.10.4
