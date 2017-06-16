From: Serhey Popovych <serhe.popovych@gmail.com>
Subject: rtnetlink: add IFLA_GROUP to ifla_policy
Date: Fri, 16 Jun 2017 15:22:24 +0300
Message-ID: <1497615744-25657-1-git-send-email-serhe.popovych@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:33457 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753348AbdFPMWg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 08:22:36 -0400
Received: by mail-lf0-f68.google.com with SMTP id u62so4018263lfg.0
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 05:22:35 -0700 (PDT)
Received: from tuxracer.synapse.com ([195.238.92.77])
        by smtp.gmail.com with ESMTPSA id v1sm418738lja.18.2017.06.16.05.22.33
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 05:22:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Network interface groups support added while ago, however
there is no IFLA_GROUP attribute description in policy
and netlink message size calculations until now.

Add IFLA_GROUP attribute to the policy.

Fixes: cbda10fa97d7 ("net_device: add support for network device groups")
Signed-off-by: Serhey Popovych <serhe.popovych@gmail.com>
---
 net/core/rtnetlink.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 2769ad9..6e4d6c2 100644
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
@@ -1506,6 +1507,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	[IFLA_PROTO_DOWN]	= { .type = NLA_U8 },
 	[IFLA_XDP]		= { .type = NLA_NESTED },
 	[IFLA_EVENT]		= { .type = NLA_U32 },
+	[IFLA_GROUP]		= { .type = NLA_U32 },
 };
 
 static const struct nla_policy ifla_info_policy[IFLA_INFO_MAX+1] = {
-- 
1.8.3.1
