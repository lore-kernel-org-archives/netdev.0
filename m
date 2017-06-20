From: Serhey Popovych <serhe.popovych@gmail.com>
Subject: [PATCH] rtnetlink: add IFLA_GROUP to ifla_policy
Date: Tue, 20 Jun 2017 14:35:23 +0300
Message-ID: <1497958523-9015-1-git-send-email-serhe.popovych@gmail.com>
References: <20170619.144843.29898198404383350.davem@davemloft.net>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35214 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751130AbdFTLfe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 07:35:34 -0400
Received: by mail-wm0-f66.google.com with SMTP id d64so22482869wmf.2
        for <netdev@vger.kernel.org>; Tue, 20 Jun 2017 04:35:33 -0700 (PDT)
In-Reply-To: <20170619.144843.29898198404383350.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Network interface groups support added while ago, however
there is no IFLA_GROUP attribute description in policy
and netlink message size calculations until now.

Add IFLA_GROUP attribute to the policy.

Fixes: cbda10fa97d7 ("net_device: add support for network device groups")
Signed-off-by: Serhey Popovych <serhe.popovych@gmail.com>
---
 v2: Rebased to kernel/git/davem/net.git
 
 net/core/rtnetlink.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 5e61456..467a2f4 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -931,6 +931,7 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
 	       + nla_total_size(1) /* IFLA_LINKMODE */
 	       + nla_total_size(4) /* IFLA_CARRIER_CHANGES */
 	       + nla_total_size(4) /* IFLA_LINK_NETNSID */
+	       + nla_total_size(4) /* IFLA_GROUP */
 	       + nla_total_size(ext_filter_mask
 			        & RTEXT_FILTER_VF ? 4 : 0) /* IFLA_NUM_VF */
 	       + rtnl_vfinfo_size(dev, ext_filter_mask) /* IFLA_VFINFO_LIST */
@@ -1468,6 +1469,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	[IFLA_LINK_NETNSID]	= { .type = NLA_S32 },
 	[IFLA_PROTO_DOWN]	= { .type = NLA_U8 },
 	[IFLA_XDP]		= { .type = NLA_NESTED },
+	[IFLA_GROUP]		= { .type = NLA_U32 },
 };
 
 static const struct nla_policy ifla_info_policy[IFLA_INFO_MAX+1] = {
-- 
1.8.3.1
