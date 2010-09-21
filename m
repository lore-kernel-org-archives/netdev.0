From: gwurster@scs.carleton.ca
Subject: (unknown)
Date: Tue, 21 Sep 2010 16:59:02 -0400
Message-ID: <E1Oy9va-0001v2-CP__6013.02797808803$1285105842$gmane$org@shakespeare.ccsl.carleton.ca>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from shakespeare.ccsl.carleton.ca ([134.117.225.11]:37219 "EHLO
	shakespeare.ccsl.carleton.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755435Ab0IUVuM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Sep 2010 17:50:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From ca1c566f51eeff4195b483addb86c6a73eaa37e0 Mon Sep 17 00:00:00 2001
From: Glenn Wurster <gwurster@scs.carleton.ca>
Date: Tue, 21 Sep 2010 16:59:00 -0400
Subject: [PATCH 2.6.36-rc3 1/1] IPv6: Create temporary address if none exists.
Cc: "David S. Miller" <davem@davemloft.net>,
 Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
 "Pekka Savola (ipv6)" <pekkas@netcore.fi>,
 James Morris <jmorris@namei.org>,
 Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
 Patrick McHardy <kaber@trash.net>,
 Stephen Hemminger <shemminger@vyatta.com>,
 Eric Dumazet <eric.dumazet@gmail.com>,
 Herbert Xu <herbert@gondor.apana.org.au>,
 netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
X-Length: 1674
X-UID: 10
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <201009211659.02014.gwurster@scs.carleton.ca>

If privacy extentions are enabled, but no current temporary address exists,
then create one when we get a router advertisement.

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

