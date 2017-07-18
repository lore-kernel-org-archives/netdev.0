From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: [PATCH net-next 05/11] net: dsa: Remove support for FDB add/del via SELF
Date: Tue, 18 Jul 2017 17:20:18 +0300
Message-ID: <1500387624-4361-6-git-send-email-arkadis@mellanox.com>
References: <1500387624-4361-1-git-send-email-arkadis@mellanox.com>
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        f.fainelli@gmail.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, Woojung.Huh@microchip.com,
        stephen@networkplumber.org, mlxsw@mellanox.com,
        Arkadi Sharshevsky <arkadis@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:36085 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752167AbdGROQz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 10:16:55 -0400
In-Reply-To: <1500387624-4361-1-git-send-email-arkadis@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

FDB add/del can be added via switchdev notification chain. Thus the support
for configuration via switchdev objects can be removed.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
---
 net/dsa/slave.c | 12 ------------
 1 file changed, 12 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 8278d08..a083287 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -250,12 +250,6 @@ static int dsa_slave_port_obj_add(struct net_device *dev,
 	 */
 
 	switch (obj->id) {
-	case SWITCHDEV_OBJ_ID_PORT_FDB:
-		if (switchdev_trans_ph_prepare(trans))
-			return 0;
-		err = dsa_port_fdb_add(dp, SWITCHDEV_OBJ_PORT_FDB(obj)->addr,
-				       SWITCHDEV_OBJ_PORT_FDB(obj)->vid);
-		break;
 	case SWITCHDEV_OBJ_ID_PORT_MDB:
 		err = dsa_port_mdb_add(dp, SWITCHDEV_OBJ_PORT_MDB(obj), trans);
 		break;
@@ -279,10 +273,6 @@ static int dsa_slave_port_obj_del(struct net_device *dev,
 	int err;
 
 	switch (obj->id) {
-	case SWITCHDEV_OBJ_ID_PORT_FDB:
-		err = dsa_port_fdb_del(dp, SWITCHDEV_OBJ_PORT_FDB(obj)->addr,
-				       SWITCHDEV_OBJ_PORT_FDB(obj)->vid);
-		break;
 	case SWITCHDEV_OBJ_ID_PORT_MDB:
 		err = dsa_port_mdb_del(dp, SWITCHDEV_OBJ_PORT_MDB(obj));
 		break;
@@ -925,8 +915,6 @@ static const struct net_device_ops dsa_slave_netdev_ops = {
 	.ndo_change_rx_flags	= dsa_slave_change_rx_flags,
 	.ndo_set_rx_mode	= dsa_slave_set_rx_mode,
 	.ndo_set_mac_address	= dsa_slave_set_mac_address,
-	.ndo_fdb_add		= switchdev_port_fdb_add,
-	.ndo_fdb_del		= switchdev_port_fdb_del,
 	.ndo_fdb_dump		= switchdev_port_fdb_dump,
 	.ndo_do_ioctl		= dsa_slave_ioctl,
 	.ndo_get_iflink		= dsa_slave_get_iflink,
-- 
2.4.11
