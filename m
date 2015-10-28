From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 09/12] mlxsw: spectrum: Fix ageing time value
Date: Wed, 28 Oct 2015 10:17:02 +0100
Message-ID: <1446023825-7162-10-git-send-email-jiri@resnulli.us>
References: <1446023825-7162-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, sagir@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:36737 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965259AbbJ1JRm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2015 05:17:42 -0400
Received: by wicfx6 with SMTP id fx6so190677566wic.1
        for <netdev@vger.kernel.org>; Wed, 28 Oct 2015 02:17:41 -0700 (PDT)
In-Reply-To: <1446023825-7162-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

The value passed through switchdev attr set is not in jiffies, but in
clock_t, so fix the convert.

Reported-by: Sagi Rotem <sagir@mellanox.com>
Fixes: 56ade8fe3f ("mlxsw: spectrum: Add initial support for Spectrum ASIC")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 1f3b12e..c2d0969 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -225,9 +225,10 @@ static int mlxsw_sp_ageing_set(struct mlxsw_sp *mlxsw_sp, u32 ageing_time)
 
 static int mlxsw_sp_port_attr_br_ageing_set(struct mlxsw_sp_port *mlxsw_sp_port,
 					    struct switchdev_trans *trans,
-					    unsigned long ageing_jiffies)
+					    unsigned long ageing_clock_t)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	unsigned long ageing_jiffies = clock_t_to_jiffies(ageing_clock_t);
 	u32 ageing_time = jiffies_to_msecs(ageing_jiffies) / 1000;
 
 	if (switchdev_trans_ph_prepare(trans))
-- 
1.9.3
