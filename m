From: Jens Rosenboom <me@jayr.de>
Subject: [PATCH net-next] ipv6: Ignore route option with ROUTER_PREF_INVALID
Date: Thu, 10 Sep 2009 18:25:11 +0200
Message-ID: <1252599911.5980.16.camel@fnki-nb00130>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Linux Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from leia.mcbone.net ([194.97.104.42]:32935 "EHLO leia.mcbone.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752762AbZIJQZP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Sep 2009 12:25:15 -0400
Received: from fnki-ws00028.freenet-ag.de ([194.97.6.48])
	by leia.mcbone.net with esmtpsa (TLS1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.69)
	(envelope-from <me@jayr.de>)
	id 1MlmSU-0006uo-1S
	for netdev@vger.kernel.org; Thu, 10 Sep 2009 16:25:18 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC4191 says that "If the Reserved (10) value is received, the Route
Information Option MUST be ignored.", so this patch makes us conform
to the RFC. This is different to the usage of the Default Router
Preference, where an invalid value must indeed be treated as
PREF_MEDIUM.

Signed-off-by: Jens Rosenboom <me@jayr.de>

---

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 1473ee0..f3635b7 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -481,7 +481,7 @@ int rt6_route_rcv(struct net_device *dev, u8 *opt,
int len,
 
 	pref = rinfo->route_pref;
 	if (pref == ICMPV6_ROUTER_PREF_INVALID)
-		pref = ICMPV6_ROUTER_PREF_MEDIUM;
+		return -EINVAL;
 
 	lifetime = addrconf_timeout_fixup(ntohl(rinfo->lifetime), HZ);
 


