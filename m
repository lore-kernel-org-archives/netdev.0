From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 2/3] mlxsw: adjust transmit fail log message level in __mlxsw_emad_transmit
Date: Thu, 27 Aug 2015 17:59:56 +0200
Message-ID: <1440691197-25780-3-git-send-email-jiri@resnulli.us>
References: <1440691197-25780-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	ogerlitz@mellanox.com, Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:33408 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751831AbbH0QAE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 12:00:04 -0400
Received: by wicge2 with SMTP id ge2so6457150wic.0
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 09:00:03 -0700 (PDT)
In-Reply-To: <1440691197-25780-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

When transmit fails, it is an error, not a warning.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Elad Raz <eladr@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index 0415ff6..dbcaf5d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -376,8 +376,8 @@ static int __mlxsw_emad_transmit(struct mlxsw_core *mlxsw_core,
 
 	err = mlxsw_core_skb_transmit(mlxsw_core->driver_priv, skb, tx_info);
 	if (err) {
-		dev_warn(mlxsw_core->bus_info->dev, "Failed to transmit EMAD (tid=%llx)\n",
-			 mlxsw_core->emad.tid);
+		dev_err(mlxsw_core->bus_info->dev, "Failed to transmit EMAD (tid=%llx)\n",
+			mlxsw_core->emad.tid);
 		dev_kfree_skb(skb);
 		return err;
 	}
-- 
1.9.3
