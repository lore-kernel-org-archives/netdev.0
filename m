From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] ethtool: set addr_assign_type to NET_ADDR_SET when addr is passed on create
Date: Sun,  6 Jan 2013 23:41:57 +0100
Message-ID: <1357512117-5581-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, bhutchings@solarflare.com,
	shemminger@vyatta.com, sassmann@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f170.google.com ([209.85.215.170]:42260 "EHLO
	mail-ea0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753169Ab3AFWmD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jan 2013 17:42:03 -0500
Received: by mail-ea0-f170.google.com with SMTP id d11so7458706eaa.15
        for <netdev@vger.kernel.org>; Sun, 06 Jan 2013 14:42:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case user passed address via netlink during create, NET_ADDR_PERM was set.
That is not correct so fix this by setting NET_ADDR_SET.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/core/rtnetlink.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 9969afb..9a419b0 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1667,9 +1667,11 @@ struct net_device *rtnl_create_link(struct net *net,
 
 	if (tb[IFLA_MTU])
 		dev->mtu = nla_get_u32(tb[IFLA_MTU]);
-	if (tb[IFLA_ADDRESS])
+	if (tb[IFLA_ADDRESS]) {
 		memcpy(dev->dev_addr, nla_data(tb[IFLA_ADDRESS]),
 				nla_len(tb[IFLA_ADDRESS]));
+		dev->addr_assign_type = NET_ADDR_SET;
+	}
 	if (tb[IFLA_BROADCAST])
 		memcpy(dev->broadcast, nla_data(tb[IFLA_BROADCAST]),
 				nla_len(tb[IFLA_BROADCAST]));
-- 
1.8.1
