From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH] [IPV6]: dst_entry leak in ip4ip6_err.
Date: Fri,  8 Feb 2008 20:01:02 +0300
Message-ID: <1202490062-1871-1-git-send-email-den@openvz.org>
Cc: netdev@vger.kernel.org, devel@openvz.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:53163 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S934606AbYBHRAi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Feb 2008 12:00:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The result of the ip_route_output is not assigned to skb. This means that
- it is leaked
- possible OOPS below dereferrencing skb->dst
- no ICMP message for this case

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv6/ip6_tunnel.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 9031e52..cd94064 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -550,6 +550,7 @@ ip4ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 			ip_rt_put(rt);
 			goto out;
 		}
+		skb2->dst = (struct dst_entry *)rt;
 	} else {
 		ip_rt_put(rt);
 		if (ip_route_input(skb2, eiph->daddr, eiph->saddr, eiph->tos,
-- 
1.5.3.rc5

