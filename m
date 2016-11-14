From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 7/8] mlxsw: reg: add the Monitoring Packet Sampling Configuration Register
Date: Mon, 14 Nov 2016 16:00:37 +0100
Message-ID: <1479135638-3580-8-git-send-email-jiri@resnulli.us>
References: <1479135638-3580-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        jhs@mojatatu.com, geert+renesas@glider.be,
        stephen@networkplumber.org, xiyou.wangcong@gmail.com,
        linux@roeck-us.net, roopa@cumulusnetworks.com,
        john.fastabend@gmail.com, simon.horman@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34046 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932786AbcKNPAt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 10:00:49 -0500
Received: by mail-wm0-f68.google.com with SMTP id g23so16112027wme.1
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 07:00:49 -0800 (PST)
In-Reply-To: <1479135638-3580-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

The MPSC register allows to configure ingress packet sampling on specific
port of the mlxsw device. The sampled packets are then trapped via
PKT_SAMPLE trap.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 38 +++++++++++++++++++++++++++++++
 1 file changed, 38 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index edad7cb..b5ab81a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -4771,6 +4771,44 @@ static inline void mlxsw_reg_mlcr_pack(char *payload, u8 local_port,
 					   MLXSW_REG_MLCR_DURATION_MAX : 0);
 }
 
+/* MPSC - Monitoring Packet Sampling Configuration Register
+ * --------------------------------------------------------
+ * MPSC Register is used to configure the Packet Sampling mechanism.
+ */
+#define MLXSW_REG_MPSC_ID 0x9080
+#define MLXSW_REG_MPSC_LEN 0x14
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
-- 
2.7.4
