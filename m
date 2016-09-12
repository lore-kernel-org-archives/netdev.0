From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 4/5] mlxsw: spectrum: Indicate support of multiple port types
Date: Mon, 12 Sep 2016 13:26:26 +0200
Message-ID: <1473679587-9112-5-git-send-email-jiri@resnulli.us>
References: <1473679587-9112-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34499 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757942AbcILL0f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 07:26:35 -0400
Received: by mail-wm0-f68.google.com with SMTP id g141so2138388wmd.1
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 04:26:34 -0700 (PDT)
In-Reply-To: <1473679587-9112-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The device can support multiple port types, so don't return on first
match.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 49b8d69..f7db669 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1705,21 +1705,23 @@ static const struct mlxsw_sp_port_link_mode mlxsw_sp_port_link_mode[] = {
 
 static u32 mlxsw_sp_from_ptys_supported_port(u32 ptys_eth_proto)
 {
+	u32 modes = 0;
+
 	if (ptys_eth_proto & (MLXSW_REG_PTYS_ETH_SPEED_10GBASE_CR |
 			      MLXSW_REG_PTYS_ETH_SPEED_10GBASE_SR |
 			      MLXSW_REG_PTYS_ETH_SPEED_40GBASE_CR4 |
 			      MLXSW_REG_PTYS_ETH_SPEED_40GBASE_SR4 |
 			      MLXSW_REG_PTYS_ETH_SPEED_100GBASE_SR4 |
 			      MLXSW_REG_PTYS_ETH_SPEED_SGMII))
-		return SUPPORTED_FIBRE;
+		modes |= SUPPORTED_FIBRE;
 
 	if (ptys_eth_proto & (MLXSW_REG_PTYS_ETH_SPEED_10GBASE_KR |
 			      MLXSW_REG_PTYS_ETH_SPEED_10GBASE_KX4 |
 			      MLXSW_REG_PTYS_ETH_SPEED_40GBASE_KR4 |
 			      MLXSW_REG_PTYS_ETH_SPEED_100GBASE_KR4 |
 			      MLXSW_REG_PTYS_ETH_SPEED_1000BASE_KX))
-		return SUPPORTED_Backplane;
-	return 0;
+		modes |= SUPPORTED_Backplane;
+	return modes;
 }
 
 static u32 mlxsw_sp_from_ptys_supported_link(u32 ptys_eth_proto)
-- 
2.5.5
