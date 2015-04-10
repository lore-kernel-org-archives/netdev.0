From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next v2 3/5] fou: always use be16 for port
Date: Fri, 10 Apr 2015 12:00:28 -0700
Message-ID: <1428692430-14465-4-git-send-email-xiyou.wangcong@gmail.com>
References: <1428692430-14465-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Tom Herbert <tom@herbertland.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33612 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752988AbbDJTAo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 15:00:44 -0400
Received: by paboj16 with SMTP id oj16so29933034pab.0
        for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 12:00:44 -0700 (PDT)
In-Reply-To: <1428692430-14465-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

udp_config.local_udp_port is be16. And iproute2 passes
network order for FOU_ATTR_PORT.

This doesn't fix any bug, just for consistency.

Cc: Tom Herbert <tom@herbertland.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv4/fou.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index ad0ee82..d61f6f9 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -23,7 +23,7 @@ struct fou {
 	struct socket *sock;
 	u8 protocol;
 	u8 flags;
-	u16 port;
+	__be16 port;
 	struct udp_offload udp_offloads;
 	struct list_head list;
 };
@@ -523,7 +523,7 @@ static int fou_create(struct net *net, struct fou_cfg *cfg,
 static int fou_destroy(struct net *net, struct fou_cfg *cfg)
 {
 	struct fou *fou;
-	u16 port = cfg->udp_config.local_udp_port;
+	__be16 port = cfg->udp_config.local_udp_port;
 	int err = -EINVAL;
 
 	spin_lock(&fou_lock);
@@ -573,7 +573,7 @@ static int parse_nl_config(struct genl_info *info,
 	}
 
 	if (info->attrs[FOU_ATTR_PORT]) {
-		u16 port = nla_get_u16(info->attrs[FOU_ATTR_PORT]);
+		__be16 port = nla_get_be16(info->attrs[FOU_ATTR_PORT]);
 
 		cfg->udp_config.local_udp_port = port;
 	}
-- 
1.8.3.1
