From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net] net: switchdev: change ageing_time type to clock_t
Date: Mon, 18 Jul 2016 15:02:06 -0400
Message-ID: <20160718190206.18620-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@mellanox.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Ido Schimmel <idosch@mellanox.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:52426 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751700AbcGRTCl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 15:02:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The switchdev value for the SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME
attribute is a clock_t and requires to use helpers such as
clock_t_to_jiffies() to convert to milliseconds.

Change ageing_time type from u32 to clock_t to make it explicit.

Fixes: f55ac58ae64c ("switchdev: add bridge ageing_time attribute")
Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/switchdev.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 9023e3e..62f6a96 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -60,7 +60,7 @@ struct switchdev_attr {
 		struct netdev_phys_item_id ppid;	/* PORT_PARENT_ID */
 		u8 stp_state;				/* PORT_STP_STATE */
 		unsigned long brport_flags;		/* PORT_BRIDGE_FLAGS */
-		u32 ageing_time;			/* BRIDGE_AGEING_TIME */
+		clock_t ageing_time;			/* BRIDGE_AGEING_TIME */
 		bool vlan_filtering;			/* BRIDGE_VLAN_FILTERING */
 	} u;
 };
-- 
2.9.0
