From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 5/6] mlxsw: reg: add the Monitoring Packet Sampling Configuration Register
Date: Wed, 12 Oct 2016 14:41:08 +0200
Message-ID: <1476276069-5315-6-git-send-email-jiri@resnulli.us>
References: <1476276069-5315-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        jhs@mojatatu.com, geert+renesas@glider.be,
        stephen@networkplumber.org, xiyou.wangcong@gmail.com,
        linux@roeck-us.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:35748 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754821AbcJLMl2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 08:41:28 -0400
Received: by mail-lf0-f67.google.com with SMTP id x79so6940050lff.2
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2016 05:41:28 -0700 (PDT)
In-Reply-To: <1476276069-5315-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotam.gi@gmail.com>

The MPSC register allows to configure ingress packet sampling on specific
port of the mlxsw device. The sampled packets are then trapped via
PKT_SAMPLE trap.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 43 +++++++++++++++++++++++++++++++
 1 file changed, 43 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 6460c72..e657865 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -4832,6 +4832,47 @@ static inline void mlxsw_reg_mlcr_pack(char *payload, u8 local_port,
 					   MLXSW_REG_MLCR_DURATION_MAX : 0);
 }
 
+/* MPSC - Monitoring Packet Sampling Configuration Register
+ * --------------------------------------------------------
+ * MPSC Register is used to configure the Packet Sampling mechanism.
+ */
+#define MLXSW_REG_MPSC_ID 0x9080
+#define MLXSW_REG_MPSC_LEN 0x14
+
+static const struct mlxsw_reg_info mlxsw_reg_mpsc = {
+	.id = MLXSW_REG_MPSC_ID,
+	.len = MLXSW_REG_MPSC_LEN,
+};
+
+/* reg_mpsc_local_port
+ * Local port number
+ * Not supported for CPU port
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, mpsc, local_port, 0x00, 16, 8);
+
+/* reg_mpsc_e
+ * Enable sampling on port local_port
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, mpsc, e, 0x04, 30, 1);
+
+/* reg_mpsc_rate
+ * Sampling rate = 1 out of rate packets (with randomization around
+ * the point). Valid values are: 1 to 3.5*10^9
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, mpsc, rate, 0x08, 0, 32);
+
+static inline void mlxsw_reg_mpsc_pack(char *payload, u8 local_port, bool e,
+				       u32 rate)
+{
+	MLXSW_REG_ZERO(mpsc, payload);
+	mlxsw_reg_mpsc_local_port_set(payload, local_port);
+	mlxsw_reg_mpsc_e_set(payload, e);
+	mlxsw_reg_mpsc_rate_set(payload, rate);
+}
+
 /* SBPR - Shared Buffer Pools Register
  * -----------------------------------
  * The SBPR configures and retrieves the shared buffer pools and configuration.
@@ -5367,6 +5408,8 @@ static inline const char *mlxsw_reg_id_str(u16 reg_id)
 		return "MTMP";
 	case MLXSW_REG_MLCR_ID:
 		return "MLCR";
+	case MLXSW_REG_MPSC_ID:
+		return "MPSC";
 	case MLXSW_REG_SBPR_ID:
 		return "SBPR";
 	case MLXSW_REG_SBCM_ID:
-- 
2.5.5
