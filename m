From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH 2/4] net: switchdev: support static FDB addresses
Date: Tue,  4 Aug 2015 01:54:41 -0400
Message-ID: <1438667683-18872-3-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1438667683-18872-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:65528 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895AbbHDFzn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 01:55:43 -0400
In-Reply-To: <1438667683-18872-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a is_static boolean to the switchdev_obj_fdb structure,
in order to set the ndm_state to either NUD_NOARP or NUD_REACHABLE.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/switchdev.h   | 1 +
 net/switchdev/switchdev.c | 2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index e90e1a0..0e296b8 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -72,6 +72,7 @@ struct switchdev_obj {
 		struct switchdev_obj_fdb {		/* PORT_FDB */
 			u8 addr[ETH_ALEN];
 			u16 vid;
+			bool is_static;
 		} fdb;
 	} u;
 };
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 28786e8..b75897c 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -810,7 +810,7 @@ static int switchdev_port_fdb_dump_cb(struct net_device *dev,
 	ndm->ndm_flags   = NTF_SELF;
 	ndm->ndm_type    = 0;
 	ndm->ndm_ifindex = dev->ifindex;
-	ndm->ndm_state   = NUD_REACHABLE;
+	ndm->ndm_state   = obj->u.fdb.is_static ? NUD_NOARP : NUD_REACHABLE;
 
 	if (nla_put(dump->skb, NDA_LLADDR, ETH_ALEN, obj->u.fdb.addr))
 		goto nla_put_failure;
-- 
2.4.6
