From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net-next 1/2] l2tp: set name_assign_type for devices created
 by l2tp_eth.c
Date: Mon, 24 Apr 2017 14:16:06 +0200
Message-ID: <062e3c5c1c8b9d6ddea34de74e98c159f78a2f0b.1493035407.git.g.nault@alphalink.fr>
References: <cover.1493035407.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:41077 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1169681AbdDXMQM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 08:16:12 -0400
Content-Disposition: inline
In-Reply-To: <cover.1493035407.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Export naming scheme used when creating l2tpeth interfaces
(/sys/class/net/<iface>/name_assign_type). This let userspace know if
the device's name has been generated automatically or defined manually.

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 net/l2tp/l2tp_eth.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
index b722d559c544..5e44b3cc1212 100644
--- a/net/l2tp/l2tp_eth.c
+++ b/net/l2tp/l2tp_eth.c
@@ -258,6 +258,7 @@ static void l2tp_eth_adjust_mtu(struct l2tp_tunnel *tunnel,
 
 static int l2tp_eth_create(struct net *net, u32 tunnel_id, u32 session_id, u32 peer_session_id, struct l2tp_session_cfg *cfg)
 {
+	unsigned char name_assign_type;
 	struct net_device *dev;
 	char name[IFNAMSIZ];
 	struct l2tp_tunnel *tunnel;
@@ -281,8 +282,11 @@ static int l2tp_eth_create(struct net *net, u32 tunnel_id, u32 session_id, u32 p
 			goto out;
 		}
 		strlcpy(name, cfg->ifname, IFNAMSIZ);
-	} else
+		name_assign_type = NET_NAME_USER;
+	} else {
 		strcpy(name, L2TP_ETH_DEV_NAME);
+		name_assign_type = NET_NAME_ENUM;
+	}
 
 	session = l2tp_session_create(sizeof(*spriv), tunnel, session_id,
 				      peer_session_id, cfg);
@@ -291,7 +295,7 @@ static int l2tp_eth_create(struct net *net, u32 tunnel_id, u32 session_id, u32 p
 		goto out;
 	}
 
-	dev = alloc_netdev(sizeof(*priv), name, NET_NAME_UNKNOWN,
+	dev = alloc_netdev(sizeof(*priv), name, name_assign_type,
 			   l2tp_eth_dev_setup);
 	if (!dev) {
 		rc = -ENOMEM;
-- 
2.11.0
