From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 10/16] mlxsw: reg: Add shared buffer configuration registers definitions
Date: Fri, 16 Oct 2015 14:01:31 +0200
Message-ID: <1444996897-2708-11-git-send-email-jiri@resnulli.us>
References: <1444996897-2708-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	linux@roeck-us.net, vivien.didelot@savoirfairelinux.com,
	andrew@lunn.ch, john.fastabend@gmail.com, David.Laight@ACULAB.COM,
	stephen@networkplumber.org, tgraf@suug.ch, jhs@mojatatu.com,
	sagir@mellanox.com, mattyk@mellanox.com, aviadr@mellanox.com
To: netdev@vger.kernel.org, ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:37914 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754018AbbJPMBy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 08:01:54 -0400
Received: by wicll6 with SMTP id ll6so7351944wic.1
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 05:01:53 -0700 (PDT)
In-Reply-To: <1444996897-2708-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Add definitions of SBPR, SBCM, SBPM, SBMM and PBMC registers that are
used to configure shared buffers.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 349 ++++++++++++++++++++++++++++++
 1 file changed, 349 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index f23f951..bb0ad09 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -1418,6 +1418,82 @@ static inline void mlxsw_reg_ppcnt_pack(char *payload, u8 local_port)
 	mlxsw_reg_ppcnt_prio_tc_set(payload, 0);
 }
 
+/* PBMC - Port Buffer Management Control Register
+ * ----------------------------------------------
+ * The PBMC register configures and retrieves the port packet buffer
+ * allocation for different Prios, and the Pause threshold management.
+ */
+#define MLXSW_REG_PBMC_ID 0x500C
+#define MLXSW_REG_PBMC_LEN 0x68
+
+static const struct mlxsw_reg_info mlxsw_reg_pbmc = {
+	.id = MLXSW_REG_PBMC_ID,
+	.len = MLXSW_REG_PBMC_LEN,
+};
+
+/* reg_pbmc_local_port
+ * Local port number.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, pbmc, local_port, 0x00, 16, 8);
+
+/* reg_pbmc_xoff_timer_value
+ * When device generates a pause frame, it uses this value as the pause
+ * timer (time for the peer port to pause in quota-512 bit time).
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, pbmc, xoff_timer_value, 0x04, 16, 16);
+
+/* reg_pbmc_xoff_refresh
+ * The time before a new pause frame should be sent to refresh the pause RW
+ * state. Using the same units as xoff_timer_value above (in quota-512 bit
+ * time).
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, pbmc, xoff_refresh, 0x04, 0, 16);
+
+/* reg_pbmc_buf_lossy
+ * The field indicates if the buffer is lossy.
+ * 0 - Lossless
+ * 1 - Lossy
+ * Access: RW
+ */
+MLXSW_ITEM32_INDEXED(reg, pbmc, buf_lossy, 0x0C, 25, 1, 0x08, 0x00, false);
+
+/* reg_pbmc_buf_epsb
+ * Eligible for Port Shared buffer.
+ * If epsb is set, packets assigned to buffer are allowed to insert the port
+ * shared buffer.
+ * When buf_lossy is MLXSW_REG_PBMC_LOSSY_LOSSY this field is reserved.
+ * Access: RW
+ */
+MLXSW_ITEM32_INDEXED(reg, pbmc, buf_epsb, 0x0C, 24, 1, 0x08, 0x00, false);
+
+/* reg_pbmc_buf_size
+ * The part of the packet buffer array is allocated for the specific buffer.
+ * Units are represented in cells.
+ * Access: RW
+ */
+MLXSW_ITEM32_INDEXED(reg, pbmc, buf_size, 0x0C, 0, 16, 0x08, 0x00, false);
+
+static inline void mlxsw_reg_pbmc_pack(char *payload, u8 local_port,
+				       u16 xoff_timer_value, u16 xoff_refresh)
+{
+	MLXSW_REG_ZERO(pbmc, payload);
+	mlxsw_reg_pbmc_local_port_set(payload, local_port);
+	mlxsw_reg_pbmc_xoff_timer_value_set(payload, xoff_timer_value);
+	mlxsw_reg_pbmc_xoff_refresh_set(payload, xoff_refresh);
+}
+
+static inline void mlxsw_reg_pbmc_lossy_buffer_pack(char *payload,
+						    int buf_index,
+						    u16 size)
+{
+	mlxsw_reg_pbmc_buf_lossy_set(payload, buf_index, 1);
+	mlxsw_reg_pbmc_buf_epsb_set(payload, buf_index, 0);
+	mlxsw_reg_pbmc_buf_size_set(payload, buf_index, size);
+}
+
 /* PSPA - Port Switch Partition Allocation
  * ---------------------------------------
  * Controls the association of a port with a switch partition and enables
@@ -1697,6 +1773,269 @@ static inline void mlxsw_reg_hpkt_pack(char *payload, u8 action, u16 trap_id)
 	mlxsw_reg_hpkt_ctrl_set(payload, MLXSW_REG_HPKT_CTRL_PACKET_DEFAULT);
 }
 
+/* SBPR - Shared Buffer Pools Register
+ * -----------------------------------
+ * The SBPR configures and retrieves the shared buffer pools and configuration.
+ */
+#define MLXSW_REG_SBPR_ID 0xB001
+#define MLXSW_REG_SBPR_LEN 0x14
+
+static const struct mlxsw_reg_info mlxsw_reg_sbpr = {
+	.id = MLXSW_REG_SBPR_ID,
+	.len = MLXSW_REG_SBPR_LEN,
+};
+
+enum mlxsw_reg_sbpr_dir {
+	MLXSW_REG_SBPR_DIR_INGRESS,
+	MLXSW_REG_SBPR_DIR_EGRESS,
+};
+
+/* reg_sbpr_dir
+ * Direction.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, sbpr, dir, 0x00, 24, 2);
+
+/* reg_sbpr_pool
+ * Pool index.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, sbpr, pool, 0x00, 0, 4);
+
+/* reg_sbpr_size
+ * Pool size in buffer cells.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, sbpr, size, 0x04, 0, 24);
+
+enum mlxsw_reg_sbpr_mode {
+	MLXSW_REG_SBPR_MODE_STATIC,
+	MLXSW_REG_SBPR_MODE_DYNAMIC,
+};
+
+/* reg_sbpr_mode
+ * Pool quota calculation mode.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, sbpr, mode, 0x08, 0, 4);
+
+static inline void mlxsw_reg_sbpr_pack(char *payload, u8 pool,
+				       enum mlxsw_reg_sbpr_dir dir,
+				       enum mlxsw_reg_sbpr_mode mode, u32 size)
+{
+	MLXSW_REG_ZERO(sbpr, payload);
+	mlxsw_reg_sbpr_pool_set(payload, pool);
+	mlxsw_reg_sbpr_dir_set(payload, dir);
+	mlxsw_reg_sbpr_mode_set(payload, mode);
+	mlxsw_reg_sbpr_size_set(payload, size);
+}
+
+/* SBCM - Shared Buffer Class Management Register
+ * ----------------------------------------------
+ * The SBCM register configures and retrieves the shared buffer allocation
+ * and configuration according to Port-PG, including the binding to pool
+ * and definition of the associated quota.
+ */
+#define MLXSW_REG_SBCM_ID 0xB002
+#define MLXSW_REG_SBCM_LEN 0x28
+
+static const struct mlxsw_reg_info mlxsw_reg_sbcm = {
+	.id = MLXSW_REG_SBCM_ID,
+	.len = MLXSW_REG_SBCM_LEN,
+};
+
+/* reg_sbcm_local_port
+ * Local port number.
+ * For Ingress: excludes CPU port and Router port
+ * For Egress: excludes IP Router
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, sbcm, local_port, 0x00, 16, 8);
+
+/* reg_sbcm_pg_buff
+ * PG buffer - Port PG (dir=ingress) / traffic class (dir=egress)
+ * For PG buffer: range is 0..cap_max_pg_buffers - 1
+ * For traffic class: range is 0..cap_max_tclass - 1
+ * Note that when traffic class is in MC aware mode then the traffic
+ * classes which are MC aware cannot be configured.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, sbcm, pg_buff, 0x00, 8, 6);
+
+enum mlxsw_reg_sbcm_dir {
+	MLXSW_REG_SBCM_DIR_INGRESS,
+	MLXSW_REG_SBCM_DIR_EGRESS,
+};
+
+/* reg_sbcm_dir
+ * Direction.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, sbcm, dir, 0x00, 0, 2);
+
+/* reg_sbcm_min_buff
+ * Minimum buffer size for the limiter, in cells.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, sbcm, min_buff, 0x18, 0, 24);
+
+/* reg_sbcm_max_buff
+ * When the pool associated to the port-pg/tclass is configured to
+ * static, Maximum buffer size for the limiter configured in cells.
+ * When the pool associated to the port-pg/tclass is configured to
+ * dynamic, the max_buff holds the "alpha" parameter, supporting
+ * the following values:
+ * 0: 0
+ * i: (1/128)*2^(i-1), for i=1..14
+ * 0xFF: Infinity
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, sbcm, max_buff, 0x1C, 0, 24);
+
+/* reg_sbcm_pool
+ * Association of the port-priority to a pool.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, sbcm, pool, 0x24, 0, 4);
+
+static inline void mlxsw_reg_sbcm_pack(char *payload, u8 local_port, u8 pg_buff,
+				       enum mlxsw_reg_sbcm_dir dir,
+				       u32 min_buff, u32 max_buff, u8 pool)
+{
+	MLXSW_REG_ZERO(sbcm, payload);
+	mlxsw_reg_sbcm_local_port_set(payload, local_port);
+	mlxsw_reg_sbcm_pg_buff_set(payload, pg_buff);
+	mlxsw_reg_sbcm_dir_set(payload, dir);
+	mlxsw_reg_sbcm_min_buff_set(payload, min_buff);
+	mlxsw_reg_sbcm_max_buff_set(payload, max_buff);
+	mlxsw_reg_sbcm_pool_set(payload, pool);
+}
+
+/* SBPM - Shared Buffer Class Management Register
+ * ----------------------------------------------
+ * The SBPM register configures and retrieves the shared buffer allocation
+ * and configuration according to Port-Pool, including the definition
+ * of the associated quota.
+ */
+#define MLXSW_REG_SBPM_ID 0xB003
+#define MLXSW_REG_SBPM_LEN 0x28
+
+static const struct mlxsw_reg_info mlxsw_reg_sbpm = {
+	.id = MLXSW_REG_SBPM_ID,
+	.len = MLXSW_REG_SBPM_LEN,
+};
+
+/* reg_sbpm_local_port
+ * Local port number.
+ * For Ingress: excludes CPU port and Router port
+ * For Egress: excludes IP Router
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, sbpm, local_port, 0x00, 16, 8);
+
+/* reg_sbpm_pool
+ * The pool associated to quota counting on the local_port.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, sbpm, pool, 0x00, 8, 4);
+
+enum mlxsw_reg_sbpm_dir {
+	MLXSW_REG_SBPM_DIR_INGRESS,
+	MLXSW_REG_SBPM_DIR_EGRESS,
+};
+
+/* reg_sbpm_dir
+ * Direction.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, sbpm, dir, 0x00, 0, 2);
+
+/* reg_sbpm_min_buff
+ * Minimum buffer size for the limiter, in cells.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, sbpm, min_buff, 0x18, 0, 24);
+
+/* reg_sbpm_max_buff
+ * When the pool associated to the port-pg/tclass is configured to
+ * static, Maximum buffer size for the limiter configured in cells.
+ * When the pool associated to the port-pg/tclass is configured to
+ * dynamic, the max_buff holds the "alpha" parameter, supporting
+ * the following values:
+ * 0: 0
+ * i: (1/128)*2^(i-1), for i=1..14
+ * 0xFF: Infinity
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, sbpm, max_buff, 0x1C, 0, 24);
+
+static inline void mlxsw_reg_sbpm_pack(char *payload, u8 local_port, u8 pool,
+				       enum mlxsw_reg_sbpm_dir dir,
+				       u32 min_buff, u32 max_buff)
+{
+	MLXSW_REG_ZERO(sbpm, payload);
+	mlxsw_reg_sbpm_local_port_set(payload, local_port);
+	mlxsw_reg_sbpm_pool_set(payload, pool);
+	mlxsw_reg_sbpm_dir_set(payload, dir);
+	mlxsw_reg_sbpm_min_buff_set(payload, min_buff);
+	mlxsw_reg_sbpm_max_buff_set(payload, max_buff);
+}
+
+/* SBMM - Shared Buffer Multicast Management Register
+ * --------------------------------------------------
+ * The SBMM register configures and retrieves the shared buffer allocation
+ * and configuration for MC packets according to Switch-Priority, including
+ * the binding to pool and definition of the associated quota.
+ */
+#define MLXSW_REG_SBMM_ID 0xB004
+#define MLXSW_REG_SBMM_LEN 0x28
+
+static const struct mlxsw_reg_info mlxsw_reg_sbmm = {
+	.id = MLXSW_REG_SBMM_ID,
+	.len = MLXSW_REG_SBMM_LEN,
+};
+
+/* reg_sbmm_prio
+ * Switch Priority.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, sbmm, prio, 0x00, 8, 4);
+
+/* reg_sbmm_min_buff
+ * Minimum buffer size for the limiter, in cells.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, sbmm, min_buff, 0x18, 0, 24);
+
+/* reg_sbmm_max_buff
+ * When the pool associated to the port-pg/tclass is configured to
+ * static, Maximum buffer size for the limiter configured in cells.
+ * When the pool associated to the port-pg/tclass is configured to
+ * dynamic, the max_buff holds the "alpha" parameter, supporting
+ * the following values:
+ * 0: 0
+ * i: (1/128)*2^(i-1), for i=1..14
+ * 0xFF: Infinity
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, sbmm, max_buff, 0x1C, 0, 24);
+
+/* reg_sbmm_pool
+ * Association of the port-priority to a pool.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, sbmm, pool, 0x24, 0, 4);
+
+static inline void mlxsw_reg_sbmm_pack(char *payload, u8 prio, u32 min_buff,
+				       u32 max_buff, u8 pool)
+{
+	MLXSW_REG_ZERO(sbmm, payload);
+	mlxsw_reg_sbmm_prio_set(payload, prio);
+	mlxsw_reg_sbmm_min_buff_set(payload, min_buff);
+	mlxsw_reg_sbmm_max_buff_set(payload, max_buff);
+	mlxsw_reg_sbmm_pool_set(payload, pool);
+}
+
 static inline const char *mlxsw_reg_id_str(u16 reg_id)
 {
 	switch (reg_id) {
@@ -1734,12 +2073,22 @@ static inline const char *mlxsw_reg_id_str(u16 reg_id)
 		return "PAOS";
 	case MLXSW_REG_PPCNT_ID:
 		return "PPCNT";
+	case MLXSW_REG_PBMC_ID:
+		return "PBMC";
 	case MLXSW_REG_PSPA_ID:
 		return "PSPA";
 	case MLXSW_REG_HTGT_ID:
 		return "HTGT";
 	case MLXSW_REG_HPKT_ID:
 		return "HPKT";
+	case MLXSW_REG_SBPR_ID:
+		return "SBPR";
+	case MLXSW_REG_SBCM_ID:
+		return "SBCM";
+	case MLXSW_REG_SBPM_ID:
+		return "SBPM";
+	case MLXSW_REG_SBMM_ID:
+		return "SBMM";
 	default:
 		return "*UNKNOWN*";
 	}
-- 
1.9.3
