From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 13/42] mlxsw: reg: Add Router Interface Table Register
Date: Fri,  1 Jul 2016 16:04:41 +0200
Message-ID: <1467381910-3445-14-git-send-email-jiri@resnulli.us>
References: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36769 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752023AbcGAOR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 10:17:26 -0400
Received: by mail-wm0-f65.google.com with SMTP id c82so5646319wme.3
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 07:17:20 -0700 (PDT)
In-Reply-To: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Add the Router Interface Table Register (RITR), which allows us to
create and configure router interfaces (RIFs).

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 194 ++++++++++++++++++++++++++++++
 1 file changed, 194 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index ea05e83..5ddc1d3 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -3262,6 +3262,198 @@ static inline void mlxsw_reg_rgcr_pack(char *payload, bool ipv4_en)
 	mlxsw_reg_rgcr_ipv4_en_set(payload, ipv4_en);
 }
 
+/* RITR - Router Interface Table Register
+ * --------------------------------------
+ * The register is used to configure the router interface table.
+ */
+#define MLXSW_REG_RITR_ID 0x8002
+#define MLXSW_REG_RITR_LEN 0x40
+
+static const struct mlxsw_reg_info mlxsw_reg_ritr = {
+	.id = MLXSW_REG_RITR_ID,
+	.len = MLXSW_REG_RITR_LEN,
+};
+
+/* reg_ritr_enable
+ * Enables routing on the router interface.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ritr, enable, 0x00, 31, 1);
+
+/* reg_ritr_ipv4
+ * IPv4 routing enable. Enables routing of IPv4 traffic on the router
+ * interface.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ritr, ipv4, 0x00, 29, 1);
+
+/* reg_ritr_ipv6
+ * IPv6 routing enable. Enables routing of IPv6 traffic on the router
+ * interface.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ritr, ipv6, 0x00, 28, 1);
+
+enum mlxsw_reg_ritr_if_type {
+	MLXSW_REG_RITR_VLAN_IF,
+	MLXSW_REG_RITR_FID_IF,
+	MLXSW_REG_RITR_SP_IF,
+};
+
+/* reg_ritr_type
+ * Router interface type.
+ * 0 - VLAN interface.
+ * 1 - FID interface.
+ * 2 - Sub-port interface.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ritr, type, 0x00, 23, 3);
+
+enum {
+	MLXSW_REG_RITR_RIF_CREATE,
+	MLXSW_REG_RITR_RIF_DEL,
+};
+
+/* reg_ritr_op
+ * Opcode:
+ * 0 - Create or edit RIF.
+ * 1 - Delete RIF.
+ * Reserved for SwitchX-2. For Spectrum, editing of interface properties
+ * is not supported. An interface must be deleted and re-created in order
+ * to update properties.
+ * Access: WO
+ */
+MLXSW_ITEM32(reg, ritr, op, 0x00, 20, 2);
+
+/* reg_ritr_rif
+ * Router interface index. A pointer to the Router Interface Table.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, ritr, rif, 0x00, 0, 16);
+
+/* reg_ritr_ipv4_fe
+ * IPv4 Forwarding Enable.
+ * Enables routing of IPv4 traffic on the router interface. When disabled,
+ * forwarding is blocked but local traffic (traps and IP2ME) will be enabled.
+ * Not supported in SwitchX-2.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ritr, ipv4_fe, 0x04, 29, 1);
+
+/* reg_ritr_ipv6_fe
+ * IPv6 Forwarding Enable.
+ * Enables routing of IPv6 traffic on the router interface. When disabled,
+ * forwarding is blocked but local traffic (traps and IP2ME) will be enabled.
+ * Not supported in SwitchX-2.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ritr, ipv6_fe, 0x04, 28, 1);
+
+/* reg_ritr_virtual_router
+ * Virtual router ID associated with the router interface.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ritr, virtual_router, 0x04, 0, 16);
+
+/* reg_ritr_mtu
+ * Router interface MTU.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ritr, mtu, 0x34, 0, 16);
+
+/* reg_ritr_if_swid
+ * Switch partition ID.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ritr, if_swid, 0x08, 24, 8);
+
+/* reg_ritr_if_mac
+ * Router interface MAC address.
+ * In Spectrum, all MAC addresses must have the same 38 MSBits.
+ * Access: RW
+ */
+MLXSW_ITEM_BUF(reg, ritr, if_mac, 0x12, 6);
+
+/* VLAN Interface */
+
+/* reg_ritr_vlan_if_vid
+ * VLAN ID.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ritr, vlan_if_vid, 0x08, 0, 12);
+
+/* FID Interface */
+
+/* reg_ritr_fid_if_fid
+ * Filtering ID. Used to connect a bridge to the router. Only FIDs from
+ * the vFID range are supported.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ritr, fid_if_fid, 0x08, 0, 16);
+
+static inline void mlxsw_reg_ritr_fid_set(char *payload,
+					  enum mlxsw_reg_ritr_if_type rif_type,
+					  u16 fid)
+{
+	if (rif_type == MLXSW_REG_RITR_FID_IF)
+		mlxsw_reg_ritr_fid_if_fid_set(payload, fid);
+	else
+		mlxsw_reg_ritr_vlan_if_vid_set(payload, fid);
+}
+
+/* Sub-port Interface */
+
+/* reg_ritr_sp_if_lag
+ * LAG indication. When this bit is set the system_port field holds the
+ * LAG identifier.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ritr, sp_if_lag, 0x08, 24, 1);
+
+/* reg_ritr_sp_system_port
+ * Port unique indentifier. When lag bit is set, this field holds the
+ * lag_id in bits 0:9.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ritr, sp_if_system_port, 0x08, 0, 16);
+
+/* reg_ritr_sp_if_vid
+ * VLAN ID.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ritr, sp_if_vid, 0x18, 0, 12);
+
+static inline void mlxsw_reg_ritr_rif_pack(char *payload, u16 rif)
+{
+	MLXSW_REG_ZERO(ritr, payload);
+	mlxsw_reg_ritr_rif_set(payload, rif);
+}
+
+static inline void mlxsw_reg_ritr_sp_if_pack(char *payload, bool lag,
+					     u16 system_port, u16 vid)
+{
+	mlxsw_reg_ritr_sp_if_lag_set(payload, lag);
+	mlxsw_reg_ritr_sp_if_system_port_set(payload, system_port);
+	mlxsw_reg_ritr_sp_if_vid_set(payload, vid);
+}
+
+static inline void mlxsw_reg_ritr_pack(char *payload, bool enable,
+				       enum mlxsw_reg_ritr_if_type type,
+				       u16 rif, u16 mtu, const char *mac)
+{
+	bool op = enable ? MLXSW_REG_RITR_RIF_CREATE : MLXSW_REG_RITR_RIF_DEL;
+
+	MLXSW_REG_ZERO(ritr, payload);
+	mlxsw_reg_ritr_enable_set(payload, enable);
+	mlxsw_reg_ritr_ipv4_set(payload, 1);
+	mlxsw_reg_ritr_type_set(payload, type);
+	mlxsw_reg_ritr_op_set(payload, op);
+	mlxsw_reg_ritr_rif_set(payload, rif);
+	mlxsw_reg_ritr_ipv4_fe_set(payload, 1);
+	mlxsw_reg_ritr_mtu_set(payload, mtu);
+	mlxsw_reg_ritr_if_mac_memcpy_to(payload, mac);
+}
+
 /* MFCR - Management Fan Control Register
  * --------------------------------------
  * This register controls the settings of the Fan Speed PWM mechanism.
@@ -4002,6 +4194,8 @@ static inline const char *mlxsw_reg_id_str(u16 reg_id)
 		return "HPKT";
 	case MLXSW_REG_RGCR_ID:
 		return "RGCR";
+	case MLXSW_REG_RITR_ID:
+		return "RITR";
 	case MLXSW_REG_MFCR_ID:
 		return "MFCR";
 	case MLXSW_REG_MFSC_ID:
-- 
2.5.5
