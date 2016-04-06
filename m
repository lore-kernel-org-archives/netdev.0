From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 14/17] mlxsw: reg: Add lossless settings for PBMC register
Date: Wed,  6 Apr 2016 17:10:13 +0200
Message-ID: <1459955416-23786-15-git-send-email-jiri@resnulli.us>
References: <1459955416-23786-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36001 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754210AbcDFPKh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 11:10:37 -0400
Received: by mail-wm0-f66.google.com with SMTP id o129so4683604wmo.3
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 08:10:36 -0700 (PDT)
In-Reply-To: <1459955416-23786-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When configuring PAUSE frames and PFC we'll need to configure the
Xon/Xoff threshold for the priority group (PG) buffers.

Add the Xon/Xoff threshold fields to the PBMC register so that we can
configure these when needed.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 35 +++++++++++++++++++++++++++++++
 1 file changed, 35 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index b83514a..bcd38ff 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -2788,6 +2788,30 @@ MLXSW_ITEM32_INDEXED(reg, pbmc, buf_epsb, 0x0C, 24, 1, 0x08, 0x00, false);
  */
 MLXSW_ITEM32_INDEXED(reg, pbmc, buf_size, 0x0C, 0, 16, 0x08, 0x00, false);
 
+/* reg_pbmc_buf_xoff_threshold
+ * Once the amount of data in the buffer goes above this value, device
+ * starts sending PFC frames for all priorities associated with the
+ * buffer. Units are represented in cells. Reserved in case of lossy
+ * buffer.
+ * Access: RW
+ *
+ * Note: In Spectrum, reserved for buffer[9].
+ */
+MLXSW_ITEM32_INDEXED(reg, pbmc, buf_xoff_threshold, 0x0C, 16, 16,
+		     0x08, 0x04, false);
+
+/* reg_pbmc_buf_xon_threshold
+ * When the amount of data in the buffer goes below this value, device
+ * stops sending PFC frames for the priorities associated with the
+ * buffer. Units are represented in cells. Reserved in case of lossy
+ * buffer.
+ * Access: RW
+ *
+ * Note: In Spectrum, reserved for buffer[9].
+ */
+MLXSW_ITEM32_INDEXED(reg, pbmc, buf_xon_threshold, 0x0C, 0, 16,
+		     0x08, 0x04, false);
+
 static inline void mlxsw_reg_pbmc_pack(char *payload, u8 local_port,
 				       u16 xoff_timer_value, u16 xoff_refresh)
 {
@@ -2806,6 +2830,17 @@ static inline void mlxsw_reg_pbmc_lossy_buffer_pack(char *payload,
 	mlxsw_reg_pbmc_buf_size_set(payload, buf_index, size);
 }
 
+static inline void mlxsw_reg_pbmc_lossless_buffer_pack(char *payload,
+						       int buf_index, u16 size,
+						       u16 threshold)
+{
+	mlxsw_reg_pbmc_buf_lossy_set(payload, buf_index, 0);
+	mlxsw_reg_pbmc_buf_epsb_set(payload, buf_index, 0);
+	mlxsw_reg_pbmc_buf_size_set(payload, buf_index, size);
+	mlxsw_reg_pbmc_buf_xoff_threshold_set(payload, buf_index, threshold);
+	mlxsw_reg_pbmc_buf_xon_threshold_set(payload, buf_index, threshold);
+}
+
 /* PSPA - Port Switch Partition Allocation
  * ---------------------------------------
  * Controls the association of a port with a switch partition and enables
-- 
2.5.5
