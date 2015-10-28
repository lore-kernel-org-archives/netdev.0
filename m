From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 10/12] mlxsw: Put constant on the right side of comparisons
Date: Wed, 28 Oct 2015 10:17:03 +0100
Message-ID: <1446023825-7162-11-git-send-email-jiri@resnulli.us>
References: <1446023825-7162-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, sagir@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:38122 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932657AbbJ1JRq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2015 05:17:46 -0400
Received: by wicll6 with SMTP id ll6so4665296wic.1
        for <netdev@vger.kernel.org>; Wed, 28 Oct 2015 02:17:45 -0700 (PDT)
In-Reply-To: <1446023825-7162-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Fixes those places where checkpatch complains that comparisons
should place the constant on the right side of the test.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.c     | 4 ++--
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index bd80ac7..97f0d93 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -287,7 +287,7 @@ static void mlxsw_emad_pack_op_tlv(char *op_tlv,
 	mlxsw_emad_op_tlv_status_set(op_tlv, 0);
 	mlxsw_emad_op_tlv_register_id_set(op_tlv, reg->id);
 	mlxsw_emad_op_tlv_r_set(op_tlv, MLXSW_EMAD_OP_TLV_REQUEST);
-	if (MLXSW_CORE_REG_ACCESS_TYPE_QUERY == type)
+	if (type == MLXSW_CORE_REG_ACCESS_TYPE_QUERY)
 		mlxsw_emad_op_tlv_method_set(op_tlv,
 					     MLXSW_EMAD_OP_TLV_METHOD_QUERY);
 	else
@@ -362,7 +362,7 @@ static bool mlxsw_emad_is_resp(const struct sk_buff *skb)
 	char *op_tlv;
 
 	op_tlv = mlxsw_emad_op_tlv(skb);
-	return (MLXSW_EMAD_OP_TLV_RESPONSE == mlxsw_emad_op_tlv_r_get(op_tlv));
+	return (mlxsw_emad_op_tlv_r_get(op_tlv) == MLXSW_EMAD_OP_TLV_RESPONSE);
 }
 
 #define MLXSW_EMAD_TIMEOUT_MS 200
diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index 50e29c4..d85960c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -1147,7 +1147,7 @@ static void mlxsw_sx_pude_event_func(const struct mlxsw_reg_info *reg,
 	}
 
 	status = mlxsw_reg_pude_oper_status_get(pude_pl);
-	if (MLXSW_PORT_OPER_STATUS_UP == status) {
+	if (status == MLXSW_PORT_OPER_STATUS_UP) {
 		netdev_info(mlxsw_sx_port->dev, "link up\n");
 		netif_carrier_on(mlxsw_sx_port->dev);
 	} else {
-- 
1.9.3
