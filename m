From: Glenn Wurster <gwurster@scs.carleton.ca>
Subject: [PATCH 2.6.36-rc3 1/1] IPv6: Create temporary address if none
	exists.
Date: Wed, 22 Sep 2010 12:04:11 -0400
Message-ID: <20100922160411.GA11185__41885.0630907857$1285174300$gmane$org@external.electric.ath.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yosh
Return-path: <netdev-owner@vger.kernel.org>
Received: from 69-55-236-88.in-addr.arpa.johncompanies.com ([69.55.236.88]:44198
	"EHLO external.dropship.ath.cx" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752998Ab0IVQvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 12:51:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If privacy extentions are enabled, but no current temporary address exists,
then create one when we get a router advertisement.

Sending again because of a previous e-mail header issue.

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
+			if ((create || list_empty(&in6_dev->tempaddr_list)) && 
in6_dev->cnf.use_tempaddr > 0) {
 				/*
 				 * When a new public address is created as described in [ADDRCONF],
-				 * also create a new temporary address.
+				 * also create a new temporary address. Also create a temporary
+				 * address if it's enabled but no temporary address currently exists.
 				 */
 				read_unlock_bh(&in6_dev->lock);
 				ipv6_create_tempaddr(ifp, NULL);

