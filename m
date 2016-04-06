From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 06/17] mlxsw: spectrum: Set port's shared buffer size to 0
Date: Wed,  6 Apr 2016 17:10:05 +0200
Message-ID: <1459955416-23786-7-git-send-email-jiri@resnulli.us>
References: <1459955416-23786-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36822 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754381AbcDFPKn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 11:10:43 -0400
Received: by mail-wm0-f67.google.com with SMTP id o129so4681999wmo.3
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 08:10:42 -0700 (PDT)
In-Reply-To: <1459955416-23786-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

In addition to the priority group (PG) buffers in the headroom, the
device enables the allocation of headroom shared buffer, which can
be shared between different PGs.

However, we are not going to use the headroom shared buffer and instead
allow the user to use its size for PGs or the switch's shared buffer.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h              | 2 ++
 drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index f08a17f..370914e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -2455,6 +2455,8 @@ MLXSW_ITEM32(reg, pbmc, xoff_timer_value, 0x04, 16, 16);
  */
 MLXSW_ITEM32(reg, pbmc, xoff_refresh, 0x04, 0, 16);
 
+#define MLXSW_REG_PBMC_PORT_SHARED_BUF_IDX 11
+
 /* reg_pbmc_buf_lossy
  * The field indicates if the buffer is lossy.
  * 0 - Lossless
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
index e7a5b73..97c8d53 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
@@ -80,6 +80,8 @@ static int mlxsw_sp_port_pb_init(struct mlxsw_sp_port *mlxsw_sp_port)
 		pb = &mlxsw_sp_pbs[i];
 		mlxsw_reg_pbmc_lossy_buffer_pack(pbmc_pl, pb->index, pb->size);
 	}
+	mlxsw_reg_pbmc_lossy_buffer_pack(pbmc_pl,
+					 MLXSW_REG_PBMC_PORT_SHARED_BUF_IDX, 0);
 	return mlxsw_reg_write(mlxsw_sp_port->mlxsw_sp->core,
 			       MLXSW_REG(pbmc), pbmc_pl);
 }
-- 
2.5.5
