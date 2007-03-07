From: Tore Anderson <tore@linpro.no>
Subject: [PATCH] Improve cached ECMP documentation
Date: Wed, 07 Mar 2007 13:37:44 +0100
Message-ID: <45EEB218.8000804@linpro.no>
References: <20070307073932.GA1675@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jarek Poplawski <jarkao2@o2.pl>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.linpro.no ([213.236.139.167]:42138 "EHLO
	mailhub.linpro.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965133AbXCGMhp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2007 07:37:45 -0500
In-Reply-To: <20070307073932.GA1675@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Document that equal-cost multipath routing with caching does not work
for forwarded packets.

Signed-Off-By: Tore Anderson <tore@linpro.no>
---

* Jarek Poplawski

> It is probably one of the most often asked questions
> on the LARTC, so I'd suggest to look at its archives.
>
> [...]
> 
> Multipath with caching doesn't work with forwarding.

  Well, I did look at LARTC's archives (and again after reading your
 mail), still couldn't find anything.  Sorry for bothering you, though.
 When I disabled the support it worked just fine (no need for iptables
 CONNMARK trickery or any of Julian's patches), so thanks for your help!

  Anyway, it strikes me as a bit odd that this feature is found under
 CONFIG_IP_ADVANCED_ROUTER when it doesn't work for routers.  That
 could at least be better documented - here's a patch to do just that.

--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -124,6 +124,10 @@ config IP_ROUTE_MULTIPATH_CACHED
 	  routing cache. If you say Y here, alternative routes are cached
 	  and on cache lookup a route is chosen in a configurable fashion.
 
+	  Be warned that this feature does not work for forwarded packets,
+	  and that enabling it will break equal cost multipath routing for
+	  forwarded traffic.
+
 	  If unsure, say N.
 
 config IP_ROUTE_MULTIPATH_RR

