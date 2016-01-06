From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 5/8] mlxsw: Fixing vlans init range
Date: Wed,  6 Jan 2016 13:01:08 +0100
Message-ID: <1452081671-8476-6-git-send-email-jiri@resnulli.us>
References: <1452081671-8476-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:36448 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752231AbcAFMBU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 07:01:20 -0500
Received: by mail-wm0-f46.google.com with SMTP id l65so56680454wmf.1
        for <netdev@vger.kernel.org>; Wed, 06 Jan 2016 04:01:20 -0800 (PST)
In-Reply-To: <1452081671-8476-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

Initialize VLANs 0..4095 (Remove init for VID 4096).

Signed-off-by: Elad Raz <eladr@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 6215954..dcf77c9 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -1201,7 +1201,8 @@ int mlxsw_sp_port_vlan_init(struct mlxsw_sp_port *mlxsw_sp_port)
 	 * with VID 1.
 	 */
 	mlxsw_sp_port->pvid = 1;
-	err = __mlxsw_sp_port_vlans_del(mlxsw_sp_port, 0, VLAN_N_VID, true);
+	err = __mlxsw_sp_port_vlans_del(mlxsw_sp_port, 0, VLAN_N_VID - 1,
+					true);
 	if (err) {
 		netdev_err(dev, "Unable to init VLANs\n");
 		return err;
-- 
1.9.3
