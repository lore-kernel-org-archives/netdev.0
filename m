From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/6] ipv4: fib: Set offload indication according to nexthop flags
Date: Wed,  2 Aug 2017 09:56:01 +0200
Message-ID: <20170802075606.1090-2-jiri@resnulli.us>
References: <20170802075606.1090-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsahern@gmail.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, hannes@stressinduktion.org,
        yoshfuji@linux-ipv6.org, kuznet@ms2.inr.ac.ru
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:33353 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750725AbdHBH4L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 03:56:11 -0400
Received: by mail-wr0-f194.google.com with SMTP id y43so3049579wrd.0
        for <netdev@vger.kernel.org>; Wed, 02 Aug 2017 00:56:11 -0700 (PDT)
In-Reply-To: <20170802075606.1090-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

We're going to have capable drivers indicate route offload using the
nexthop flags, but for non-multipath routes these flags aren't dumped to
user space.

Instead, set the offload indication in the route message flags.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/ipv4/fib_semantics.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index b8d1817..f62dc24 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -1342,6 +1342,8 @@ int fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
 			    IN_DEV_IGNORE_ROUTES_WITH_LINKDOWN(in_dev))
 				rtm->rtm_flags |= RTNH_F_DEAD;
 		}
+		if (fi->fib_nh->nh_flags & RTNH_F_OFFLOAD)
+			rtm->rtm_flags |= RTNH_F_OFFLOAD;
 #ifdef CONFIG_IP_ROUTE_CLASSID
 		if (fi->fib_nh[0].nh_tclassid &&
 		    nla_put_u32(skb, RTA_FLOW, fi->fib_nh[0].nh_tclassid))
-- 
2.9.3
