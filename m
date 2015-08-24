From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/3] mlxsw: adjust log messages level in __mlxsw_emad_transmit
Date: Mon, 24 Aug 2015 16:45:47 +0200
Message-ID: <1440427547-8539-4-git-send-email-jiri@resnulli.us>
References: <1440427547-8539-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	ogerlitz@mellanox.com, Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:34129 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754357AbbHXOpy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 10:45:54 -0400
Received: by widdq5 with SMTP id dq5so52674323wid.1
        for <netdev@vger.kernel.org>; Mon, 24 Aug 2015 07:45:53 -0700 (PDT)
In-Reply-To: <1440427547-8539-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

When transmit fails, it is an error, not a warning.
Do not warn when timeout happens as that is handled by a counter.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Elad Raz <eladr@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index 6ee3f45..dfafb83 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -382,8 +382,8 @@ static int __mlxsw_emad_transmit(struct mlxsw_core *mlxsw_core,
 
 	err = mlxsw_core_skb_transmit(mlxsw_core->driver_priv, skb, tx_info);
 	if (err) {
-		dev_warn(mlxsw_core->bus_info->dev, "Failed to transmit EMAD (tid=%llx)\n",
-			 mlxsw_core->emad.tid);
+		dev_err(mlxsw_core->bus_info->dev, "Failed to transmit EMAD (tid=%llx)\n",
+			mlxsw_core->emad.tid);
 		dev_kfree_skb(skb);
 		return err;
 	}
@@ -393,8 +393,8 @@ static int __mlxsw_emad_transmit(struct mlxsw_core *mlxsw_core,
 				 !(mlxsw_core->emad.trans_active),
 				 msecs_to_jiffies(MLXSW_EMAD_TIMEOUT_MS));
 	if (!ret) {
-		dev_warn(mlxsw_core->bus_info->dev, "EMAD timed-out (tid=%llx)\n",
-			 mlxsw_core->emad.tid);
+		dev_dbg(mlxsw_core->bus_info->dev, "EMAD timed-out (tid=%llx)\n",
+			mlxsw_core->emad.tid);
 		mlxsw_core->emad.trans_active = false;
 		mlxsw_core->emad.stats.timeouts++;
 		return -EIO;
-- 
1.9.3
