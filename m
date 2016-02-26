From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 8/9] mlxsw: spectrum: Mark unused ports using NULL
Date: Fri, 26 Feb 2016 17:32:30 +0100
Message-ID: <1456504351-18871-9-git-send-email-jiri@resnulli.us>
References: <1456504351-18871-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, yishaih@mellanox.com,
	dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, eugenia@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	hadarh@mellanox.com, jhs@mojatatu.com, john.fastabend@gmail.com,
	jeffrey.t.kirsher@intel.com, brouer@redhat.com, ivecera@redhat.com,
	rami.rosen@intel.com, hannes@stressinduktion.org,
	gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35154 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030306AbcBZQcr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 11:32:47 -0500
Received: by mail-wm0-f67.google.com with SMTP id g62so9942523wme.2
        for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 08:32:47 -0800 (PST)
In-Reply-To: <1456504351-18871-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When splitting and unsplitting we'll destroy usable ports on the fly, so
mark them using a NULL pointer to indicate that their local port number
is free and can be re-used.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 240881c..926019e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1518,6 +1518,7 @@ static void mlxsw_sp_port_remove(struct mlxsw_sp *mlxsw_sp, u8 local_port)
 
 	if (!mlxsw_sp_port)
 		return;
+	mlxsw_sp->ports[local_port] = NULL;
 	devlink_port = &mlxsw_sp_port->devlink_port;
 	devlink_port_type_clear(devlink_port);
 	unregister_netdev(mlxsw_sp_port->dev); /* This calls ndo_stop */
-- 
2.5.0
