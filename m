From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net] rtnl: fix msg size calculation in if_nlmsg_size()
Date: Thu, 31 Mar 2016 18:10:31 +0200
Message-ID: <1459440631-31729-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	David Ahern <dsahern@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:59670 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750828AbcCaQLQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 12:11:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Size of the attribute IFLA_PHYS_PORT_NAME was missing.

Fixes: db24a9044ee1 ("net: add support for phys_port_name")
CC: David Ahern <dsahern@gmail.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/core/rtnetlink.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index f2066772d0f3..a75f7e94b445 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -909,6 +909,7 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
 	       + rtnl_link_get_af_size(dev, ext_filter_mask) /* IFLA_AF_SPEC */
 	       + nla_total_size(MAX_PHYS_ITEM_ID_LEN) /* IFLA_PHYS_PORT_ID */
 	       + nla_total_size(MAX_PHYS_ITEM_ID_LEN) /* IFLA_PHYS_SWITCH_ID */
+	       + nla_total_size(IFNAMSIZ) /* IFLA_PHYS_PORT_NAME */
 	       + nla_total_size(1); /* IFLA_PROTO_DOWN */
 
 }
-- 
2.4.2
