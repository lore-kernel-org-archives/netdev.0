From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH] net: ipv6: set route type for anycast routes
Date: Wed, 15 Mar 2017 18:14:33 -0700
Message-ID: <1489626873-5371-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:34209 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750788AbdCPBPP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 21:15:15 -0400
Received: by mail-pf0-f175.google.com with SMTP id v190so16355329pfb.1
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 18:15:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anycast routes have the RTF_ANYCAST flag set, but when dumping routes
for userspace the route type is not set to RTN_ANYCAST. Make it so.

Fixes: 58c4fb86eabcb ("[IPV6]: Flag RTF_ANYCAST for anycast routes")
CC: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv6/route.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 35c58b669ebd..9db1418993f2 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -3423,6 +3423,8 @@ static int rt6_fill_node(struct net *net,
 	}
 	else if (rt->rt6i_flags & RTF_LOCAL)
 		rtm->rtm_type = RTN_LOCAL;
+	else if (rt->rt6i_flags & RTF_ANYCAST)
+		rtm->rtm_type = RTN_ANYCAST;
 	else if (rt->dst.dev && (rt->dst.dev->flags & IFF_LOOPBACK))
 		rtm->rtm_type = RTN_LOCAL;
 	else
-- 
2.1.4
