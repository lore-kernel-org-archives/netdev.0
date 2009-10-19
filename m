From: John Dykstra <john.dykstra1@gmail.com>
Subject: PATCH [net-next-2.6] IP: Cleanups
Date: Mon, 19 Oct 2009 14:31:30 -0500
Message-ID: <1255980690.20673.5.camel@Maple>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.188]:49986 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753988AbZJSTbe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2009 15:31:34 -0400
Received: by gv-out-0910.google.com with SMTP id r4so485586gve.37
        for <netdev@vger.kernel.org>; Mon, 19 Oct 2009 12:31:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've been sitting on these waiting to accumulate more, but that isn't
likely to happen short-term.

---
Use symbols instead of magic constants while checking PMTU discovery
setsockopt.

Remove redundant test in ip_rt_frag_needed() (done by caller).

Signed-off-by: John Dykstra <john.dykstra1@gmail.com>
---
 net/ipv4/ip_sockglue.c   |    2 +-
 net/ipv4/route.c         |    3 ---
 net/ipv6/ipv6_sockglue.c |    2 +-
 3 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index c602d98..2445fed 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -575,7 +575,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 		inet->hdrincl = val ? 1 : 0;
 		break;
 	case IP_MTU_DISCOVER:
-		if (val < 0 || val > 3)
+		if (val < IP_PMTUDISC_DONT || val > IP_PMTUDISC_PROBE)
 			goto e_inval;
 		inet->pmtudisc = val;
 		break;
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 39e10ac..68566de 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -662,7 +662,7 @@ done:
 	case IPV6_MTU_DISCOVER:
 		if (optlen < sizeof(int))
 			goto e_inval;
-		if (val<0 || val>3)
+		if (val < IP_PMTUDISC_DONT || val > IP_PMTUDISC_PROBE)
 			goto e_inval;
 		np->pmtudisc = val;
 		retv = 0;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index bb41992..68fb227 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1628,9 +1628,6 @@ unsigned short ip_rt_frag_needed(struct net *net, struct iphdr *iph,
 	__be32  daddr = iph->daddr;
 	unsigned short est_mtu = 0;
 
-	if (ipv4_config.no_pmtu_disc)
-		return 0;
-
 	for (k = 0; k < 2; k++) {
 		for (i = 0; i < 2; i++) {
 			unsigned hash = rt_hash(daddr, skeys[i], ikeys[k],-- 
1.5.4.3



