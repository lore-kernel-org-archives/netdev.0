From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: Remove redundant oif checks in rt6_device_match
Date: Fri, 25 Sep 2015 15:22:54 -0600
Message-ID: <1443216174-72579-1-git-send-email-dsa@cumulusnetworks.com>
Cc: yoshfuji@linux-ipv6.org, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:32996 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933361AbbIYVXB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 17:23:01 -0400
Received: by pacex6 with SMTP id ex6so115956063pac.0
        for <netdev@vger.kernel.org>; Fri, 25 Sep 2015 14:23:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The oif has already been checked that it is non-zero; the 2 additional
checks on oif within that if (oif) {...} block are redundant.

CC: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv6/route.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 118f8fa1a809..934dd9c6aa86 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -474,10 +474,10 @@ static inline struct rt6_info *rt6_device_match(struct net *net,
 			if (dev->flags & IFF_LOOPBACK) {
 				if (!sprt->rt6i_idev ||
 				    sprt->rt6i_idev->dev->ifindex != oif) {
-					if (flags & RT6_LOOKUP_F_IFACE && oif)
+					if (flags & RT6_LOOKUP_F_IFACE)
 						continue;
-					if (local && (!oif ||
-						      local->rt6i_idev->dev->ifindex == oif))
+					if (local &&
+					    local->rt6i_idev->dev->ifindex == oif)
 						continue;
 				}
 				local = sprt;
-- 
2.3.8 (Apple Git-58)
