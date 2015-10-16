From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 09/16] mlxsw: reg: Add Switch Port VID and Switch Port VLAN Membership registers definitions
Date: Fri, 16 Oct 2015 14:01:30 +0200
Message-ID: <1444996897-2708-10-git-send-email-jiri@resnulli.us>
References: <1444996897-2708-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	linux@roeck-us.net, vivien.didelot@savoirfairelinux.com,
	andrew@lunn.ch, john.fastabend@gmail.com, David.Laight@ACULAB.COM,
	stephen@networkplumber.org, tgraf@suug.ch, jhs@mojatatu.com,
	sagir@mellanox.com, mattyk@mellanox.com, aviadr@mellanox.com
To: netdev@vger.kernel.org, ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:36725 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754082AbbJPMBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 08:01:53 -0400
Received: by wicgb1 with SMTP id gb1so6391774wic.1
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 05:01:52 -0700 (PDT)
In-Reply-To: <1444996897-2708-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

Add SPVID and SPVM registers responsible for default port VID
configuration and VLAN membership of a port.

Signed-off-by: Elad Raz <eladr@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 146 ++++++++++++++++++++++++++++++
 1 file changed, 146 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 8afa2b6..f23f951 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -517,6 +517,148 @@ static inline void mlxsw_reg_spms_vid_pack(char *payload, u16 vid,
 	mlxsw_reg_spms_state_set(payload, vid, state);
 }
 
+/* SPVID - Switch Port VID
+ * -----------------------
+ * The switch port VID configures the default VID for a port.
+ */
+#define MLXSW_REG_SPVID_ID 0x200E
+#define MLXSW_REG_SPVID_LEN 0x08
+
+static const struct mlxsw_reg_info mlxsw_reg_spvid = {
+	.id = MLXSW_REG_SPVID_ID,
+	.len = MLXSW_REG_SPVID_LEN,
+};
+
+/* reg_spvid_local_port
+ * Local port number.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, spvid, local_port, 0x00, 16, 8);
+
+/* reg_spvid_sub_port
+ * Virtual port within the physical port.
+ * Should be set to 0 when virtual ports are not enabled on the port.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, spvid, sub_port, 0x00, 8, 8);
+
+/* reg_spvid_pvid
+ * Port default VID
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, spvid, pvid, 0x04, 0, 12);
+
+static inline void mlxsw_reg_spvid_pack(char *payload, u8 local_port, u16 pvid)
+{
+	MLXSW_REG_ZERO(spvid, payload);
+	mlxsw_reg_spvid_local_port_set(payload, local_port);
+	mlxsw_reg_spvid_pvid_set(payload, pvid);
+}
+
+/* SPVM - Switch Port VLAN Membership
+ * ----------------------------------
+ * The Switch Port VLAN Membership register configures the VLAN membership
+ * of a port in a VLAN denoted by VID. VLAN membership is managed per
+ * virtual port. The register can be used to add and remove VID(s) from a port.
+ */
+#define MLXSW_REG_SPVM_ID 0x200F
+#define MLXSW_REG_SPVM_BASE_LEN 0x04 /* base length, without records */
+#define MLXSW_REG_SPVM_REC_LEN 0x04 /* record length */
+#define MLXSW_REG_SPVM_REC_MAX_COUNT 256
+#define MLXSW_REG_SPVM_LEN (MLXSW_REG_SPVM_BASE_LEN +	\
+		    MLXSW_REG_SPVM_REC_LEN * MLXSW_REG_SPVM_REC_MAX_COUNT)
+
+static const struct mlxsw_reg_info mlxsw_reg_spvm = {
+	.id = MLXSW_REG_SPVM_ID,
+	.len = MLXSW_REG_SPVM_LEN,
+};
+
+/* reg_spvm_pt
+ * Priority tagged. If this bit is set, packets forwarded to the port with
+ * untagged VLAN membership (u bit is set) will be tagged with priority tag
+ * (VID=0)
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, spvm, pt, 0x00, 31, 1);
+
+/* reg_spvm_pte
+ * Priority Tagged Update Enable. On Write operations, if this bit is cleared,
+ * the pt bit will NOT be updated. To update the pt bit, pte must be set.
+ * Access: WO
+ */
+MLXSW_ITEM32(reg, spvm, pte, 0x00, 30, 1);
+
+/* reg_spvm_local_port
+ * Local port number.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, spvm, local_port, 0x00, 16, 8);
+
+/* reg_spvm_sub_port
+ * Virtual port within the physical port.
+ * Should be set to 0 when virtual ports are not enabled on the port.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, spvm, sub_port, 0x00, 8, 8);
+
+/* reg_spvm_num_rec
+ * Number of records to update. Each record contains: i, e, u, vid.
+ * Access: OP
+ */
+MLXSW_ITEM32(reg, spvm, num_rec, 0x00, 0, 8);
+
+/* reg_spvm_rec_i
+ * Ingress membership in VLAN ID.
+ * Access: Index
+ */
+MLXSW_ITEM32_INDEXED(reg, spvm, rec_i,
+		     MLXSW_REG_SPVM_BASE_LEN, 14, 1,
+		     MLXSW_REG_SPVM_REC_LEN, 0, false);
+
+/* reg_spvm_rec_e
+ * Egress membership in VLAN ID.
+ * Access: Index
+ */
+MLXSW_ITEM32_INDEXED(reg, spvm, rec_e,
+		     MLXSW_REG_SPVM_BASE_LEN, 13, 1,
+		     MLXSW_REG_SPVM_REC_LEN, 0, false);
+
+/* reg_spvm_rec_u
+ * Untagged - port is an untagged member - egress transmission uses untagged
+ * frames on VID<n>
+ * Access: Index
+ */
+MLXSW_ITEM32_INDEXED(reg, spvm, rec_u,
+		     MLXSW_REG_SPVM_BASE_LEN, 12, 1,
+		     MLXSW_REG_SPVM_REC_LEN, 0, false);
+
+/* reg_spvm_rec_vid
+ * Egress membership in VLAN ID.
+ * Access: Index
+ */
+MLXSW_ITEM32_INDEXED(reg, spvm, rec_vid,
+		     MLXSW_REG_SPVM_BASE_LEN, 0, 12,
+		     MLXSW_REG_SPVM_REC_LEN, 0, false);
+
+static inline void mlxsw_reg_spvm_pack(char *payload, u8 local_port,
+				       u16 vid_begin, u16 vid_end,
+				       bool is_member, bool untagged)
+{
+	int size = vid_end - vid_begin + 1;
+	int i;
+
+	MLXSW_REG_ZERO(spvm, payload);
+	mlxsw_reg_spvm_local_port_set(payload, local_port);
+	mlxsw_reg_spvm_num_rec_set(payload, size);
+
+	for (i = 0; i < size; i++) {
+		mlxsw_reg_spvm_rec_i_set(payload, i, is_member);
+		mlxsw_reg_spvm_rec_e_set(payload, i, is_member);
+		mlxsw_reg_spvm_rec_u_set(payload, i, untagged);
+		mlxsw_reg_spvm_rec_vid_set(payload, i, vid_begin + i);
+	}
+}
+
 /* SFGC - Switch Flooding Group Configuration
  * ------------------------------------------
  * The following register controls the association of flooding tables and MIDs
@@ -1570,6 +1712,10 @@ static inline const char *mlxsw_reg_id_str(u16 reg_id)
 		return "SFN";
 	case MLXSW_REG_SPMS_ID:
 		return "SPMS";
+	case MLXSW_REG_SPVID_ID:
+		return "SPVID";
+	case MLXSW_REG_SPVM_ID:
+		return "SPVM";
 	case MLXSW_REG_SFGC_ID:
 		return "SFGC";
 	case MLXSW_REG_SFTR_ID:
-- 
1.9.3
