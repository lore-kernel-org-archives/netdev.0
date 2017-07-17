From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 4/4] mlxsw: spectrum: Improve IPv6 unregistered multicast flooding
Date: Mon, 17 Jul 2017 14:15:32 +0200
Message-ID: <20170717121532.4036-5-jiri@resnulli.us>
References: <20170717121532.4036-1-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:34699 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751301AbdGQMPl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 08:15:41 -0400
Received: by mail-wr0-f194.google.com with SMTP id w4so969685wrb.1
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 05:15:41 -0700 (PDT)
In-Reply-To: <20170717121532.4036-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Up until now IPv6 unregistered multicast traffic would be flooded like
broadcast, even when MLD snooping was enabled on the bridge. This was
intentional as MLD packet traps were missing, preventing the bridge
driver from programming MDB entries to the device.

Previous patch added these traps, so we can now finally flood IPv6
unregistered multicast packets to specific ports via the multicast table
instead of flooding them to all ports via the broadcast table.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_fid.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_fid.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_fid.c
index 6afbe9e..bbd238e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_fid.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_fid.c
@@ -109,7 +109,6 @@ static const int mlxsw_sp_sfgc_uc_packet_types[MLXSW_REG_SFGC_TYPE_MAX] = {
 
 static const int mlxsw_sp_sfgc_bc_packet_types[MLXSW_REG_SFGC_TYPE_MAX] = {
 	[MLXSW_REG_SFGC_TYPE_BROADCAST]				= 1,
-	[MLXSW_REG_SFGC_TYPE_UNREGISTERED_MULTICAST_IPV6]	= 1,
 	[MLXSW_REG_SFGC_TYPE_UNREGISTERED_MULTICAST_NON_IP]	= 1,
 	[MLXSW_REG_SFGC_TYPE_IPV4_LINK_LOCAL]			= 1,
 	[MLXSW_REG_SFGC_TYPE_IPV6_ALL_HOST]			= 1,
@@ -117,6 +116,7 @@ static const int mlxsw_sp_sfgc_bc_packet_types[MLXSW_REG_SFGC_TYPE_MAX] = {
 
 static const int mlxsw_sp_sfgc_mc_packet_types[MLXSW_REG_SFGC_TYPE_MAX] = {
 	[MLXSW_REG_SFGC_TYPE_UNREGISTERED_MULTICAST_IPV4]	= 1,
+	[MLXSW_REG_SFGC_TYPE_UNREGISTERED_MULTICAST_IPV6]	= 1,
 };
 
 static const int *mlxsw_sp_packet_type_sfgc_types[] = {
-- 
2.9.3
