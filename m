From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/4] IPv6: keep route for tentative address
Date: Mon, 12 Apr 2010 08:41:31 -0700
Message-ID: <20100412154255.641453741@vyatta.com>
References: <20100412154130.397252857@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:47327 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751999Ab0DLPqi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Apr 2010 11:46:38 -0400
Content-Disposition: inline; filename=ipv6-addrconf1.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recent changes preserve IPv6 address when link goes down (good).
But would cause address to point to dead dst entry (bad).
The simplest fix is to just not delete route if address is
being held for later use.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/ipv6/addrconf.c	2010-04-11 12:19:37.938082190 -0700
+++ b/net/ipv6/addrconf.c	2010-04-11 12:25:05.349309074 -0700
@@ -4046,7 +4046,8 @@ static void __ipv6_ifa_notify(int event,
 			addrconf_leave_anycast(ifp);
 		addrconf_leave_solict(ifp->idev, &ifp->addr);
 		dst_hold(&ifp->rt->u.dst);
-		if (ip6_del_rt(ifp->rt))
+
+		if (ifp->dead && ip6_del_rt(ifp->rt))
 			dst_free(&ifp->rt->u.dst);
 		break;
 	}

-- 

