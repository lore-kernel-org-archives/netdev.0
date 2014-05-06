From: Sergey Popovich <popovich_sergei@mail.ru>
Subject: [PATCH 3/3] rtnetlink: add IFLA_GROUP to ifla_policy
Date: Tue,  6 May 2014 18:13:17 +0300
Message-ID: <9796c92d09ec7371c7c1dee3a2dc5af09099791c.1399388943.git.popovich_sergei@mail.ru>
References: <cover.1399388943.git.popovich_sergei@mail.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback3.mail.ru ([94.100.176.58]:38477 "EHLO
	fallback3.mail.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756945AbaEFPQC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 11:16:02 -0400
Received: from smtp10.mail.ru (smtp10.mail.ru [94.100.176.152])
	by fallback3.mail.ru (mPOP.Fallback_MX) with ESMTP id F1139114C376C
	for <netdev@vger.kernel.org>; Tue,  6 May 2014 19:14:00 +0400 (MSK)
Received: from [195.234.68.4] (port=41193 helo=tuxracer.skif.com.ua)
	by smtp10.mail.ru with esmtpa (envelope-from <popovich_sergei@mail.ru>)
	id 1Whh3w-0004LE-Mx
	for netdev@vger.kernel.org; Tue, 06 May 2014 19:13:44 +0400
In-Reply-To: <cover.1399388943.git.popovich_sergei@mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Network interface groups support added while ago, however
there is no IFLA_GROUP attribute description in policy
until now.

Add IFLA_GROUP attribute to the policy.

Fixes: cbda10fa97d7 net_device: add support for network device groups

Signed-off-by: Sergey Popovich <popovich_sergei@mail.ru>
---
 net/core/rtnetlink.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 188c060..7ee8565 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -823,6 +823,7 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
 	       + nla_total_size(1) /* IFLA_OPERSTATE */
 	       + nla_total_size(1) /* IFLA_LINKMODE */
 	       + nla_total_size(4) /* IFLA_CARRIER_CHANGES */
+	       + nla_total_size(4) /* IFLA_GROUP */
 	       + nla_total_size(ext_filter_mask
 			        & RTEXT_FILTER_VF ? 4 : 0) /* IFLA_NUM_VF */
 	       + rtnl_vfinfo_size(dev, ext_filter_mask) /* IFLA_VFINFO_LIST */
@@ -1151,6 +1152,7 @@ static const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_NUM_RX_QUEUES]	= { .type = NLA_U32 },
 	[IFLA_PHYS_PORT_ID]	= { .type = NLA_BINARY, .len = MAX_PHYS_PORT_ID_LEN },
 	[IFLA_CARRIER_CHANGES]	= { .type = NLA_U32 },  /* ignored */
+	[IFLA_GROUP]		= { .type = NLA_U32 },
 };
 
 static const struct nla_policy ifla_info_policy[IFLA_INFO_MAX+1] = {
-- 
1.8.3.4
