From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH net 1/3] ip6_tunnel: Return an error when adding an existing tunnel.
Date: Mon, 22 Sep 2014 10:07:24 +0200
Message-ID: <1411373246-22389-2-git-send-email-steffen.klassert@secunet.com>
References: <1411373246-22389-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53890 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753171AbaIVIHr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Sep 2014 04:07:47 -0400
In-Reply-To: <1411373246-22389-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip6_tnl_locate() should not return an existing tunnel if
create is true. Otherwise it is possible to add the same
tunnel multiple times without getting an error.

So return NULL if the tunnel that should be created already
exists.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/ip6_tunnel.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index f9de5a6..69a84b4 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -364,8 +364,12 @@ static struct ip6_tnl *ip6_tnl_locate(struct net *net,
 	     (t = rtnl_dereference(*tp)) != NULL;
 	     tp = &t->next) {
 		if (ipv6_addr_equal(local, &t->parms.laddr) &&
-		    ipv6_addr_equal(remote, &t->parms.raddr))
+		    ipv6_addr_equal(remote, &t->parms.raddr)) {
+			if (create)
+				return NULL;
+
 			return t;
+		}
 	}
 	if (!create)
 		return NULL;
-- 
1.9.1
