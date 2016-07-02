From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 11/12] mlxsw: spectrum: Use action 'discard' when removing traps
Date: Sat,  2 Jul 2016 11:00:19 +0200
Message-ID: <1467450020-23415-12-git-send-email-jiri@resnulli.us>
References: <1467450020-23415-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35057 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752336AbcGBJAo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jul 2016 05:00:44 -0400
Received: by mail-wm0-f67.google.com with SMTP id a66so10282534wme.2
        for <netdev@vger.kernel.org>; Sat, 02 Jul 2016 02:00:44 -0700 (PDT)
In-Reply-To: <1467450020-23415-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When removing packet traps we should use action 'discard' instead of
'forward', as some trap IDs we'll add cannot be configured with the
later. However, result is the same, as packets are not trapped to the
CPU.

In the future we will be able to reverse the operation properly by
detaching the trap group from the CPU.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index d15ebf3..de30763 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2295,7 +2295,7 @@ err_rx_trap_set:
 					  mlxsw_sp);
 err_rx_listener_register:
 	for (i--; i >= 0; i--) {
-		mlxsw_reg_hpkt_pack(hpkt_pl, MLXSW_REG_HPKT_ACTION_FORWARD,
+		mlxsw_reg_hpkt_pack(hpkt_pl, MLXSW_REG_HPKT_ACTION_DISCARD,
 				    mlxsw_sp_rx_listener[i].trap_id);
 		mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(hpkt), hpkt_pl);
 
@@ -2312,7 +2312,7 @@ static void mlxsw_sp_traps_fini(struct mlxsw_sp *mlxsw_sp)
 	int i;
 
 	for (i = 0; i < ARRAY_SIZE(mlxsw_sp_rx_listener); i++) {
-		mlxsw_reg_hpkt_pack(hpkt_pl, MLXSW_REG_HPKT_ACTION_FORWARD,
+		mlxsw_reg_hpkt_pack(hpkt_pl, MLXSW_REG_HPKT_ACTION_DISCARD,
 				    mlxsw_sp_rx_listener[i].trap_id);
 		mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(hpkt), hpkt_pl);
 
-- 
2.5.5
