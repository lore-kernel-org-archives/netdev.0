From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net] pppox: use standard module auto-loading feature
Date: Wed, 2 Dec 2015 16:27:39 +0100
Message-ID: <02bfd73648a0cf563213d58daefe8b8de580a70a.1449067422.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Kozlov <xeb@mail.ru>, James Chapman <jchapman@katalix.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:42704 "EHLO
	zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752494AbbLBP1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 10:27:47 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  * Register PF_PPPOX with pppox module rather than with pppoe,
    so that pppoe doesn't get loaded for any PF_PPPOX socket.

  * Register PX_PROTO_* with standard MODULE_ALIAS_NET_PF_PROTO()
    instead of using pppox's own naming scheme.

  * While there, add auto-loading feature for pptp.

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 drivers/net/ppp/pppoe.c | 2 +-
 drivers/net/ppp/pppox.c | 3 ++-
 drivers/net/ppp/pptp.c  | 1 +
 net/l2tp/l2tp_ppp.c     | 2 +-
 4 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ppp/pppoe.c b/drivers/net/ppp/pppoe.c
index 277e682..b8da2ea 100644
--- a/drivers/net/ppp/pppoe.c
+++ b/drivers/net/ppp/pppoe.c
@@ -1202,4 +1202,4 @@ module_exit(pppoe_exit);
 MODULE_AUTHOR("Michal Ostrowski <mostrows@speakeasy.net>");
 MODULE_DESCRIPTION("PPP over Ethernet driver");
 MODULE_LICENSE("GPL");
-MODULE_ALIAS_NETPROTO(PF_PPPOX);
+MODULE_ALIAS_NET_PF_PROTO(PF_PPPOX, PX_PROTO_OE);
diff --git a/drivers/net/ppp/pppox.c b/drivers/net/ppp/pppox.c
index 0200de7..b9c8be6 100644
--- a/drivers/net/ppp/pppox.c
+++ b/drivers/net/ppp/pppox.c
@@ -113,7 +113,7 @@ static int pppox_create(struct net *net, struct socket *sock, int protocol,
 
 	rc = -EPROTONOSUPPORT;
 	if (!pppox_protos[protocol])
-		request_module("pppox-proto-%d", protocol);
+		request_module("net-pf-%d-proto-%d", PF_PPPOX, protocol);
 	if (!pppox_protos[protocol] ||
 	    !try_module_get(pppox_protos[protocol]->owner))
 		goto out;
@@ -147,3 +147,4 @@ module_exit(pppox_exit);
 MODULE_AUTHOR("Michal Ostrowski <mostrows@speakeasy.net>");
 MODULE_DESCRIPTION("PPP over Ethernet driver (generic socket layer)");
 MODULE_LICENSE("GPL");
+MODULE_ALIAS_NETPROTO(PF_PPPOX);
diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
index fc69e41..e18e0980b 100644
--- a/drivers/net/ppp/pptp.c
+++ b/drivers/net/ppp/pptp.c
@@ -718,3 +718,4 @@ module_exit(pptp_exit_module);
 MODULE_DESCRIPTION("Point-to-Point Tunneling Protocol");
 MODULE_AUTHOR("D. Kozlov (xeb@mail.ru)");
 MODULE_LICENSE("GPL");
+MODULE_ALIAS_NET_PF_PROTO(PF_PPPOX, PX_PROTO_PPTP);
diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index 1ad18c5..d93f113 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -1862,5 +1862,5 @@ MODULE_AUTHOR("James Chapman <jchapman@katalix.com>");
 MODULE_DESCRIPTION("PPP over L2TP over UDP");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(PPPOL2TP_DRV_VERSION);
-MODULE_ALIAS("pppox-proto-" __stringify(PX_PROTO_OL2TP));
+MODULE_ALIAS_NET_PF_PROTO(PF_PPPOX, PX_PROTO_OL2TP);
 MODULE_ALIAS_L2TP_PWTYPE(11);
-- 
2.6.2
