From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH net 2/3] ip6_vti: Return an error when adding an existing tunnel.
Date: Mon, 22 Sep 2014 10:07:25 +0200
Message-ID: <1411373246-22389-3-git-send-email-steffen.klassert@secunet.com>
References: <1411373246-22389-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53894 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753247AbaIVIHw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Sep 2014 04:07:52 -0400
In-Reply-To: <1411373246-22389-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vti6_locate() should not return an existing tunnel if
create is true. Otherwise it is possible to add the same
tunnel multiple times without getting an error.

So return NULL if the tunnel that should be created already
exists.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/ip6_vti.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index 7f52fd9..5833a22 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -253,8 +253,12 @@ static struct ip6_tnl *vti6_locate(struct net *net, struct __ip6_tnl_parm *p,
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
