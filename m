From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/2] IPv6: keep route for tentative address
Date: Mon, 24 May 2010 11:31:18 -0700
Message-ID: <20100524113118.47cc9852@nehalam>
References: <20100412154130.397252857@vyatta.com>
	<20100412154255.641453741@vyatta.com>
	<EA929A9653AAE14F841771FB1DE5A1365FE4FCE12C@rrsmsx501.amr.corp.intel.com>
	<AANLkTin3CfATS0-ePL5WUSiuq0seRCQgM6xc-YwxpPEy@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	Greg KH <greg@kroah.com>, stable@kernel.org
To: Emil S Tantilov <emils.tantilov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53450 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757681Ab0EXSdO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 May 2010 14:33:14 -0400
In-Reply-To: <AANLkTin3CfATS0-ePL5WUSiuq0seRCQgM6xc-YwxpPEy@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recent changes preserve IPv6 address when link goes down (good).
But would cause address to point to dead dst entry (bad).
The simplest fix is to just not delete route if address is
being held for later use.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
(cherry picked from commit 93fa159abe50d3c55c7f83622d3f5c09b6e06f4b)
---
Patch is for 2.6.34-stable (problem doesn't exist in earlier kernel)

 net/ipv6/addrconf.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 413054f..12e9558 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4047,7 +4047,8 @@ static void __ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
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
1.7.0.4

