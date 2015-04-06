From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 3/5] fou: fix byte order of udp_config.local_udp_port
Date: Mon,  6 Apr 2015 16:41:28 -0700
Message-ID: <1428363690-16288-4-git-send-email-xiyou.wangcong@gmail.com>
References: <1428363690-16288-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Tom Herbert <therbert@google.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34757 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753104AbbDFXlo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2015 19:41:44 -0400
Received: by pacyx8 with SMTP id yx8so58703887pac.1
        for <netdev@vger.kernel.org>; Mon, 06 Apr 2015 16:41:44 -0700 (PDT)
In-Reply-To: <1428363690-16288-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

udp_config.local_udp_port is be16. And iproute2 passes
network order for FOU_ATTR_PORT.

Cc: Tom Herbert <therbert@google.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv4/fou.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index ad0ee82..cf606fc 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -468,7 +468,7 @@ static int fou_create(struct net *net, struct fou_cfg *cfg,
 	sk = sock->sk;
 
 	fou->flags = cfg->flags;
-	fou->port = cfg->udp_config.local_udp_port;
+	fou->port = ntohs(cfg->udp_config.local_udp_port);
 
 	/* Initial for fou type */
 	switch (cfg->type) {
@@ -523,7 +523,7 @@ static int fou_create(struct net *net, struct fou_cfg *cfg,
 static int fou_destroy(struct net *net, struct fou_cfg *cfg)
 {
 	struct fou *fou;
-	u16 port = cfg->udp_config.local_udp_port;
+	u16 port = ntohs(cfg->udp_config.local_udp_port);
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
