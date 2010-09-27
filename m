From: Glenn Wurster <gwurster@scs.carleton.ca>
Subject: [PATCH linux-2.6 v2] IPv6:  Create temporary address if none
	exists.
Date: Mon, 27 Sep 2010 13:04:30 -0400
Message-ID: <20100927170430.GA7106@adams.ccsl.carleton.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yosh
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If privacy extentions are enabled, but no current temporary address exists,
then create one when we get a router advertisement.

Version 2, now with 100% fewer line wraps.  Thanks to David Miller for
pointing out the line wrapping issue.

Signed-off-by: Glenn Wurster <gwurster@scs.carleton.ca>
---
 net/ipv6/addrconf.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index ab70a3f..cfee6ae 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2022,10 +2022,11 @@ ok:
 					ipv6_ifa_notify(0, ift);
 			}
 
-			if (create && in6_dev->cnf.use_tempaddr > 0) {
+			if ((create || list_empty(&in6_dev->tempaddr_list)) && in6_dev->cnf.use_tempaddr > 0) {
 				/*
 				 * When a new public address is created as described in [ADDRCONF],
-				 * also create a new temporary address.
+				 * also create a new temporary address. Also create a temporary
+				 * address if it's enabled but no temporary address currently exists.
 				 */
 				read_unlock_bh(&in6_dev->lock);
 				ipv6_create_tempaddr(ifp, NULL);
-- 
1.5.6.5
