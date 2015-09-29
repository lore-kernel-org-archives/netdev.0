From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v2 net-next 2/6] net: switchdev: move dev in switchdev_fdb_dump
Date: Tue, 29 Sep 2015 12:07:14 -0400
Message-ID: <1443542838-19234-3-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1443542838-19234-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ip-208-88-110-44.savoirfairelinux.net ([208.88.110.44]:33790
	"EHLO mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934581AbbI2QHo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 12:07:44 -0400
In-Reply-To: <1443542838-19234-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The FDB dump callback requires the related net_device so move it to the
struct switchdev_fdb_dump superset instead of using a callback param.

With this done, it'll be simpler to change the dump function signature.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/switchdev/switchdev.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 56d34ed..c0e2047 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -858,6 +858,7 @@ EXPORT_SYMBOL_GPL(switchdev_port_fdb_del);
 
 struct switchdev_fdb_dump {
 	struct switchdev_obj obj;
+	struct net_device *dev;
 	struct sk_buff *skb;
 	struct netlink_callback *cb;
 	int idx;
@@ -887,7 +888,7 @@ static int switchdev_port_fdb_dump_cb(struct net_device *dev,
 	ndm->ndm_pad2    = 0;
 	ndm->ndm_flags   = NTF_SELF;
 	ndm->ndm_type    = 0;
-	ndm->ndm_ifindex = dev->ifindex;
+	ndm->ndm_ifindex = dump->dev->ifindex;
 	ndm->ndm_state   = obj->u.fdb.ndm_state;
 
 	if (nla_put(dump->skb, NDA_LLADDR, ETH_ALEN, obj->u.fdb.addr))
@@ -927,6 +928,7 @@ int switchdev_port_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
 			.id = SWITCHDEV_OBJ_PORT_FDB,
 			.cb = switchdev_port_fdb_dump_cb,
 		},
+		.dev = dev,
 		.skb = skb,
 		.cb = cb,
 		.idx = idx,
-- 
2.6.0
