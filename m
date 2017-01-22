From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/4] mlxsw: reg: add the Monitoring Packet Sampling Configuration Register
Date: Sun, 22 Jan 2017 12:44:46 +0100
Message-ID: <1485085487-2652-4-git-send-email-jiri@resnulli.us>
References: <1485085487-2652-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        jhs@mojatatu.com, geert+renesas@glider.be,
        stephen@networkplumber.org, xiyou.wangcong@gmail.com,
        linux@roeck-us.net, roopa@cumulusnetworks.com,
        john.fastabend@gmail.com, simon.horman@netronome.com,
        mrv@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36851 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751291AbdAVLoy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2017 06:44:54 -0500
Received: by mail-wm0-f66.google.com with SMTP id r126so18851303wmr.3
        for <netdev@vger.kernel.org>; Sun, 22 Jan 2017 03:44:53 -0800 (PST)
In-Reply-To: <1485085487-2652-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

The MPSC register allows to configure ingress packet sampling on specific
port of the mlxsw device. The sampled packets are then trapped via
PKT_SAMPLE trap.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 41 +++++++++++++++++++++++++++++++
 1 file changed, 41 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 1357fe0..9fb0316 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -4965,6 +4965,46 @@ static inline void mlxsw_reg_mlcr_pack(char *payload, u8 local_port,
 					   MLXSW_REG_MLCR_DURATION_MAX : 0);
 }
 
+/* MPSC - Monitoring Packet Sampling Configuration Register
+ * --------------------------------------------------------
+ * MPSC Register is used to configure the Packet Sampling mechanism.
+ */
+#define MLXSW_REG_MPSC_ID 0x9080
+#define MLXSW_REG_MPSC_LEN 0x1C
+
+MLXSW_REG_DEFINE(mpsc, MLXSW_REG_MPSC_ID, MLXSW_REG_MPSC_LEN);
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
+#define MLXSW_REG_MPSC_RATE_MAX 3500000000UL
+
+/* reg_mpsc_rate
+ * Sampling rate = 1 out of rate packets (with randomization around
+ * the point). Valid values are: 1 to MLXSW_REG_MPSC_RATE_MAX
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
@@ -5429,6 +5469,7 @@ static const struct mlxsw_reg_info *mlxsw_reg_infos[] = {
 	MLXSW_REG(mpat),
 	MLXSW_REG(mpar),
 	MLXSW_REG(mlcr),
+	MLXSW_REG(mpsc),
 	MLXSW_REG(sbpr),
 	MLXSW_REG(sbcm),
 	MLXSW_REG(sbpm),
-- 
2.7.4
