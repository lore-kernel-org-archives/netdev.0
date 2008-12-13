From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 01/11] icsk: join error paths using goto
Date: Sat, 13 Dec 2008 21:17:41 +0200
Message-ID: <1229195871718-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <12291958711278-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45295 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919AbYLMTRy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 14:17:54 -0500
In-Reply-To: <12291958711278-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/inet_connection_sock.c |   19 ++++++++++---------
 1 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection=
_sock.c
index fe32255..c7cda1c 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -344,16 +344,17 @@ struct dst_entry *inet_csk_route_req(struct sock =
*sk,
 	struct net *net =3D sock_net(sk);
=20
 	security_req_classify_flow(req, &fl);
-	if (ip_route_output_flow(net, &rt, &fl, sk, 0)) {
-		IP_INC_STATS_BH(net, IPSTATS_MIB_OUTNOROUTES);
-		return NULL;
-	}
-	if (opt && opt->is_strictroute && rt->rt_dst !=3D rt->rt_gateway) {
-		ip_rt_put(rt);
-		IP_INC_STATS_BH(net, IPSTATS_MIB_OUTNOROUTES);
-		return NULL;
-	}
+	if (ip_route_output_flow(net, &rt, &fl, sk, 0))
+		goto no_route;
+	if (opt && opt->is_strictroute && rt->rt_dst !=3D rt->rt_gateway)
+		goto route_err;
 	return &rt->u.dst;
+
+route_err:
+	ip_rt_put(rt);
+no_route:
+	IP_INC_STATS_BH(net, IPSTATS_MIB_OUTNOROUTES);
+	return NULL;
 }
=20
 EXPORT_SYMBOL_GPL(inet_csk_route_req);
--=20
1.5.2.2

