From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH net 3/3] ip6_gre: Return an error when adding an existing tunnel.
Date: Mon, 22 Sep 2014 10:07:26 +0200
Message-ID: <1411373246-22389-4-git-send-email-steffen.klassert@secunet.com>
References: <1411373246-22389-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53884 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752984AbaIVIHp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Sep 2014 04:07:45 -0400
In-Reply-To: <1411373246-22389-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip6gre_tunnel_locate() should not return an existing tunnel if
create is true. Otherwise it is possible to add the same
tunnel multiple times without getting an error.

So return NULL if the tunnel that should be created already
exists.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/ip6_gre.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 5f19dfb..2e5a882 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -314,6 +314,8 @@ static struct ip6_tnl *ip6gre_tunnel_locate(struct net *net,
 	struct ip6gre_net *ign = net_generic(net, ip6gre_net_id);
 
 	t = ip6gre_tunnel_find(net, parms, ARPHRD_IP6GRE);
+	if (t && create)
+		return NULL;
 	if (t || !create)
 		return t;
 
-- 
1.9.1
