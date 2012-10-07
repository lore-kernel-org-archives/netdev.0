From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net 0/6] ipv4: Changes for rt_gateway
Date: Sun,  7 Oct 2012 14:26:02 +0300
Message-ID: <1349609168-9848-1-git-send-email-ja@ssi.bg>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:50415 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750740Ab2JGLU4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Oct 2012 07:20:56 -0400
Received: from ja.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.14.4/8.14.4) with ESMTP id q97BQH2d009876
	for <netdev@vger.kernel.org>; Sun, 7 Oct 2012 14:26:17 +0300
Received: (from root@localhost)
	by ja.ssi.bg (8.14.4/8.14.4/Submit) id q97BQHDh009874
	for netdev@vger.kernel.org; Sun, 7 Oct 2012 14:26:17 +0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	This patchset fixes some problems for the routing caused
by the new rt_gateway semantics. What started as a fix for
IPVS-DR ended as fixes for more problems. To solve the IPVS
problem I decided to name the flag FLOWI_FLAG_KNOWN_NH, so that
we can even get route cached in FNHE or FIB NH.

	Different flag FLOWI_FLAG_RT_NOCACHE could be equally good
for IPVS, we again would be able to use data from fnhe but working
with cached routes should be preferred. If there is no FNHE, the
common case is IPVS to get uncached route, of course, IPVS caches
it itself.

	Patches 1-3 are fixes not related to IPVS problem,
4 and 5 add code that will be used by IPVS in patch 6.

Julian Anastasov (6):
  ipv4: fix sending of redirects
  ipv4: fix forwarding for strict source routes
  ipv4: add check if nh_pcpu_rth_output is allocated
  ipv4: introduce rt_uses_gateway
  ipv4: Add FLOWI_FLAG_KNOWN_NH
  ipvs: fix ARP resolving for direct routing mode

 include/net/flow.h              |    1 +
 include/net/route.h             |    3 +-
 net/ipv4/fib_frontend.c         |    3 +-
 net/ipv4/inet_connection_sock.c |    4 +-
 net/ipv4/ip_forward.c           |    2 +-
 net/ipv4/ip_output.c            |    4 +-
 net/ipv4/route.c                |   96 ++++++++++++++++++++++++---------------
 net/ipv4/xfrm4_policy.c         |    1 +
 net/netfilter/ipvs/ip_vs_xmit.c |    6 ++-
 9 files changed, 75 insertions(+), 45 deletions(-)

-- 
1.7.3.4
