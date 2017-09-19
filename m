From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 11/13] mlxsw: reg: Configure RIF to forward IPv4 multicast packets by default
Date: Tue, 19 Sep 2017 10:00:18 +0200
Message-ID: <20170919080020.5870-12-jiri@resnulli.us>
References: <20170919080020.5870-1-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:38242 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751623AbdISIAd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 04:00:33 -0400
Received: by mail-wr0-f193.google.com with SMTP id p37so1701071wrb.5
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 01:00:32 -0700 (PDT)
In-Reply-To: <20170919080020.5870-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

Turn on two bits on the Spectrum RIF configuration:
 - IPv4 multicast: when a multicast packet arrives on a RIF, send it to go
   through multicast routes lookup.
 - IPv4 multicast forwarding enable: when multicast packet arrives on a
   RIF, allow it to be forwarded by multicast routes. If this bit is not
   set, multicast packets will go through multicast routing lookup but will
   be dropped at the egress of the ports.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 31d120a..c203e0d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -3991,6 +3991,12 @@ MLXSW_ITEM32(reg, ritr, ipv4, 0x00, 29, 1);
  */
 MLXSW_ITEM32(reg, ritr, ipv6, 0x00, 28, 1);
 
+/* reg_ritr_ipv4_mc
+ * IPv4 multicast routing enable.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ritr, ipv4_mc, 0x00, 27, 1);
+
 enum mlxsw_reg_ritr_if_type {
 	/* VLAN interface. */
 	MLXSW_REG_RITR_VLAN_IF,
@@ -4048,6 +4054,14 @@ MLXSW_ITEM32(reg, ritr, ipv4_fe, 0x04, 29, 1);
  */
 MLXSW_ITEM32(reg, ritr, ipv6_fe, 0x04, 28, 1);
 
+/* reg_ritr_ipv4_mc_fe
+ * IPv4 Multicast Forwarding Enable.
+ * When disabled, forwarding is blocked but local traffic (traps and IP to me)
+ * will be enabled.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ritr, ipv4_mc_fe, 0x04, 27, 1);
+
 /* reg_ritr_lb_en
  * Loop-back filter enable for unicast packets.
  * If the flag is set then loop-back filter for unicast packets is
@@ -4270,11 +4284,13 @@ static inline void mlxsw_reg_ritr_pack(char *payload, bool enable,
 	mlxsw_reg_ritr_enable_set(payload, enable);
 	mlxsw_reg_ritr_ipv4_set(payload, 1);
 	mlxsw_reg_ritr_ipv6_set(payload, 1);
+	mlxsw_reg_ritr_ipv4_mc_set(payload, 1);
 	mlxsw_reg_ritr_type_set(payload, type);
 	mlxsw_reg_ritr_op_set(payload, op);
 	mlxsw_reg_ritr_rif_set(payload, rif);
 	mlxsw_reg_ritr_ipv4_fe_set(payload, 1);
 	mlxsw_reg_ritr_ipv6_fe_set(payload, 1);
+	mlxsw_reg_ritr_ipv4_mc_fe_set(payload, 1);
 	mlxsw_reg_ritr_lb_en_set(payload, 1);
 	mlxsw_reg_ritr_virtual_router_set(payload, vr_id);
 	mlxsw_reg_ritr_mtu_set(payload, mtu);
-- 
2.9.5
