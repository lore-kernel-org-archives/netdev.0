From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [RFC PATCH net-next 0/1] Add support of ECMPv6
Date: Wed, 12 Sep 2012 10:29:56 +0200
Message-ID: <1347438597-4233-1-git-send-email-nicolas.dichtel@6wind.com>
References: <87a9x3vxzp.fsf@guybrush.luffy.cx>
To: bernat@luffy.cx, netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:41400 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751596Ab2ILI3d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2012 04:29:33 -0400
In-Reply-To: <87a9x3vxzp.fsf@guybrush.luffy.cx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is a proposal to add the support of ECMPv6. The previous patch
from Vincent against iproute2 can be used, but a little other patch is needed
too:

diff --git a/ip/iproute.c b/ip/iproute.c
index 2fe44b3..b71f150 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -693,8 +693,10 @@ int parse_nexthops(struct nlmsghdr *n, struct rtmsg *r, int argc, char **argv)
 		rtnh = RTNH_NEXT(rtnh);
 	}
 
-	if (rta->rta_len > RTA_LENGTH(0))
+	if (rta->rta_len > RTA_LENGTH(0)) {
 		addattr_l(n, 1024, RTA_MULTIPATH, RTA_DATA(rta), RTA_PAYLOAD(rta));
+		n->nlmsg_flags &= ~NLM_F_EXCL;
+	}
 	return 0;
 }
 

If the kernel patch is approved, I will submit formally the patch for
iproute2.

Here is an example of a command to add an ECMP route:
$ ip -6 route add 3ffe:304:124:2306::/64 \
	nexthop via fe80::230:1bff:feb4:e05c dev eth0 weight 1 \
	nexthop via fe80::230:1bff:feb4:dd4f dev eth0 weight 1

Comments are welcome.

Regards,
Nicolas
