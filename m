From: Greg KH <gregkh@suse.de>
Subject: [071/205] IPv6: keep route for tentative address
Date: Fri, 30 Jul 2010 10:51:28 -0700
Message-ID: <20100730175140.078725467@clark.site>
References: <20100730175238.GA3924@kroah.com>
Cc: stable-review@kernel.org, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk,
	NetDev <netdev@vger.kernel.org>, Greg KH <greg@kroah.com>,
	"David S. Miller" <davem@davemloft.net>,
	<emil.s.tantilov@intel.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: linux-kernel@vger.kernel.org, stable@kernel.org,
	Emil S Tantilov <emils.tantilov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100730175238.GA3924@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2.6.34-stable review patch.  If anyone has any objections, please let us know.

------------------

From: Stephen Hemminger <shemminger@vyatta.com>

(cherry picked from commit 93fa159abe50d3c55c7f83622d3f5c09b6e06f4b)

Recent changes preserve IPv6 address when link goes down (good).
But would cause address to point to dead dst entry (bad).
The simplest fix is to just not delete route if address is
being held for later use.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 net/ipv6/addrconf.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4047,7 +4047,8 @@ static void __ipv6_ifa_notify(int event,
 			addrconf_leave_anycast(ifp);
 		addrconf_leave_solict(ifp->idev, &ifp->addr);
 		dst_hold(&ifp->rt->u.dst);
-		if (ip6_del_rt(ifp->rt))
+
+		if (ifp->dead && ip6_del_rt(ifp->rt))
 			dst_free(&ifp->rt->u.dst);
 		break;
 	}
