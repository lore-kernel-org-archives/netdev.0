From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 04/21] mlxsw: reg: Add mlxsw_reg_ralue_act_ip2me_tun_pack()
Date: Sat,  2 Sep 2017 23:49:12 +0200
Message-ID: <20170902214929.2890-5-jiri@resnulli.us>
References: <20170902214929.2890-1-jiri@resnulli.us>
Cc: davem@davemloft.net, petrm@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35939 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752790AbdIBVtk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 2 Sep 2017 17:49:40 -0400
Received: by mail-wm0-f65.google.com with SMTP id p17so3153791wmd.3
        for <netdev@vger.kernel.org>; Sat, 02 Sep 2017 14:49:39 -0700 (PDT)
In-Reply-To: <20170902214929.2890-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petr Machata <petrm@mellanox.com>

To implement IP-in-IP decapsulation, Spectrum uses LPM entries of type
IP2ME with tunnel validity bit and tunnel pointer set. The necessary
register fields are already available, so add a function to pack the
RALUE as appropriate.

Signed-off-by: Petr Machata <petrm@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index bf936b6..24296cf 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -5054,6 +5054,15 @@ mlxsw_reg_ralue_act_ip2me_pack(char *payload)
 					MLXSW_REG_RALUE_ACTION_TYPE_IP2ME);
 }
 
+static inline void
+mlxsw_reg_ralue_act_ip2me_tun_pack(char *payload, u32 tunnel_ptr)
+{
+	mlxsw_reg_ralue_action_type_set(payload,
+					MLXSW_REG_RALUE_ACTION_TYPE_IP2ME);
+	mlxsw_reg_ralue_ip2me_v_set(payload, 1);
+	mlxsw_reg_ralue_ip2me_tunnel_ptr_set(payload, tunnel_ptr);
+}
+
 /* RAUHT - Router Algorithmic LPM Unicast Host Table Register
  * ----------------------------------------------------------
  * The RAUHT register is used to configure and query the Unicast Host table in
-- 
2.9.3
