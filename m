From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 11/11] mlxsw: reg: Use correct offset in field definiton
Date: Wed, 27 Jan 2016 15:20:26 +0100
Message-ID: <1453904426-4960-12-git-send-email-jiri@resnulli.us>
References: <1453904426-4960-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35330 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933094AbcA0OUo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2016 09:20:44 -0500
Received: by mail-wm0-f65.google.com with SMTP id l66so583277wml.2
        for <netdev@vger.kernel.org>; Wed, 27 Jan 2016 06:20:43 -0800 (PST)
In-Reply-To: <1453904426-4960-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The rx_lane, tx_lane and module fields in the PMLP register don't have
an additional offset besides the base one (0x04), so set it to 0x00.

Fixes: 4ec14b7634b2 ("mlxsw: Add interface to access registers and process events")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 815e5df..bb77e22 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -1787,20 +1787,20 @@ MLXSW_ITEM32(reg, pmlp, width, 0x00, 0, 8);
  * Module number.
  * Access: RW
  */
-MLXSW_ITEM32_INDEXED(reg, pmlp, module, 0x04, 0, 8, 0x04, 0, false);
+MLXSW_ITEM32_INDEXED(reg, pmlp, module, 0x04, 0, 8, 0x04, 0x00, false);
 
 /* reg_pmlp_tx_lane
  * Tx Lane. When rxtx field is cleared, this field is used for Rx as well.
  * Access: RW
  */
-MLXSW_ITEM32_INDEXED(reg, pmlp, tx_lane, 0x04, 16, 2, 0x04, 16, false);
+MLXSW_ITEM32_INDEXED(reg, pmlp, tx_lane, 0x04, 16, 2, 0x04, 0x00, false);
 
 /* reg_pmlp_rx_lane
  * Rx Lane. When rxtx field is cleared, this field is ignored and Rx lane is
  * equal to Tx lane.
  * Access: RW
  */
-MLXSW_ITEM32_INDEXED(reg, pmlp, rx_lane, 0x04, 24, 2, 0x04, 24, false);
+MLXSW_ITEM32_INDEXED(reg, pmlp, rx_lane, 0x04, 24, 2, 0x04, 0x00, false);
 
 static inline void mlxsw_reg_pmlp_pack(char *payload, u8 local_port)
 {
-- 
1.9.3
