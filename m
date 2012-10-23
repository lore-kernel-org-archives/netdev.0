From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2 2/2] ip: remove NLM_F_EXCL in case of ECMPv6 routes
Date: Tue, 23 Oct 2012 14:42:56 +0200
Message-ID: <1350996176-4000-2-git-send-email-nicolas.dichtel@6wind.com>
References: <20121023.023910.80461258323920266.davem@davemloft.net>
 <1350996176-4000-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, joe@perches.com, bernat@luffy.cx,
	eric.dumazet@gmail.com, yoshfuji@linux-ipv6.org,
	davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:32953 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753273Ab2JWMe7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 08:34:59 -0400
In-Reply-To: <1350996176-4000-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ECMPv6 routes are added each one after the other by the kernel, so we should
avoid to set the flag NLM_F_EXCL.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 ip/iproute.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index c60156f..799a70e 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -694,8 +694,11 @@ int parse_nexthops(struct nlmsghdr *n, struct rtmsg *r, int argc, char **argv)
 		rtnh = RTNH_NEXT(rtnh);
 	}
 
-	if (rta->rta_len > RTA_LENGTH(0))
+	if (rta->rta_len > RTA_LENGTH(0)) {
 		addattr_l(n, 1024, RTA_MULTIPATH, RTA_DATA(rta), RTA_PAYLOAD(rta));
+		if (r->rtm_family == AF_INET6)
+			n->nlmsg_flags &= ~NLM_F_EXCL;
+	}
 	return 0;
 }
 
-- 
1.7.12
