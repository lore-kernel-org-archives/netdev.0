From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 01/19] net: switchdev: Add support for querying supported bridge flags by hardware
Date: Mon,  5 Jun 2017 11:20:25 +0200
Message-ID: <20170605092043.3523-2-jiri@resnulli.us>
References: <20170605092043.3523-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com, roopa@cumulusnetworks.com,
        stephen@networkplumber.org, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35152 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751723AbdFEJUr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 05:20:47 -0400
Received: by mail-wm0-f68.google.com with SMTP id g15so28759638wmc.2
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 02:20:47 -0700 (PDT)
In-Reply-To: <20170605092043.3523-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

This is done as a preparation stage before setting the bridge port flags
from the bridge code. Currently the device can be queried for the bridge
flags state, but the querier cannot distinguish if the flag is disabled
or if it is not supported at all. Thus, add new attr and a bit-mask which
include information regarding the support on a per-flag basis.

Drivers that support bridge offload but not support bridge flags should
return zeroed bitmask.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/switchdev.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 929d6af..63a754d 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -46,6 +46,7 @@ enum switchdev_attr_id {
 	SWITCHDEV_ATTR_ID_PORT_PARENT_ID,
 	SWITCHDEV_ATTR_ID_PORT_STP_STATE,
 	SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS,
+	SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS_SUPPORT,
 	SWITCHDEV_ATTR_ID_PORT_MROUTER,
 	SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME,
 	SWITCHDEV_ATTR_ID_BRIDGE_VLAN_FILTERING,
@@ -62,6 +63,7 @@ struct switchdev_attr {
 		struct netdev_phys_item_id ppid;	/* PORT_PARENT_ID */
 		u8 stp_state;				/* PORT_STP_STATE */
 		unsigned long brport_flags;		/* PORT_BRIDGE_FLAGS */
+		unsigned long brport_flags_support;	/* PORT_BRIDGE_FLAGS_SUPPORT */
 		bool mrouter;				/* PORT_MROUTER */
 		clock_t ageing_time;			/* BRIDGE_AGEING_TIME */
 		bool vlan_filtering;			/* BRIDGE_VLAN_FILTERING */
-- 
2.9.3
