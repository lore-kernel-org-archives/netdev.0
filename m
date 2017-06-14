From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/2] mlxsw: reg: Add MCIA register for cable info access
Date: Wed, 14 Jun 2017 09:27:39 +0200
Message-ID: <20170614072740.1243-2-jiri@resnulli.us>
References: <20170614072740.1243-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:33666 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754505AbdFNH17 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 03:27:59 -0400
Received: by mail-wr0-f194.google.com with SMTP id v104so36670359wrb.0
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 00:27:54 -0700 (PDT)
In-Reply-To: <20170614072740.1243-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

The MCIA register is used to access the SFP+ and QSFP connector's
EPROM. It will be used to query the cable info.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 76 +++++++++++++++++++++++++++++++
 1 file changed, 76 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 157b9b6..1bd34d9 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -5491,6 +5491,81 @@ static inline void mlxsw_reg_mtmp_unpack(char *payload, unsigned int *p_temp,
 		mlxsw_reg_mtmp_sensor_name_memcpy_from(payload, sensor_name);
 }
 
+/* MCIA - Management Cable Info Access
+ * -----------------------------------
+ * MCIA register is used to access the SFP+ and QSFP connector's EPROM.
+ */
+
+#define MLXSW_REG_MCIA_ID 0x9014
+#define MLXSW_REG_MCIA_LEN 0x40
+
+MLXSW_REG_DEFINE(mcia, MLXSW_REG_MCIA_ID, MLXSW_REG_MCIA_LEN);
+
+/* reg_mcia_l
+ * Lock bit. Setting this bit will lock the access to the specific
+ * cable. Used for updating a full page in a cable EPROM. Any access
+ * other then subsequence writes will fail while the port is locked.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, mcia, l, 0x00, 31, 1);
+
+/* reg_mcia_module
+ * Module number.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, mcia, module, 0x00, 16, 8);
+
+/* reg_mcia_status
+ * Module status.
+ * Access: RO
+ */
+MLXSW_ITEM32(reg, mcia, status, 0x00, 0, 8);
+
+/* reg_mcia_i2c_device_address
+ * I2C device address.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, mcia, i2c_device_address, 0x04, 24, 8);
+
+/* reg_mcia_page_number
+ * Page number.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, mcia, page_number, 0x04, 16, 8);
+
+/* reg_mcia_device_address
+ * Device address.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, mcia, device_address, 0x04, 0, 16);
+
+/* reg_mcia_size
+ * Number of bytes to read/write (up to 48 bytes).
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, mcia, size, 0x08, 0, 16);
+
+#define MLXSW_SP_REG_MCIA_EEPROM_SIZE 48
+
+/* reg_mcia_eeprom
+ * Bytes to read/write.
+ * Access: RW
+ */
+MLXSW_ITEM_BUF(reg, mcia, eeprom, 0x10, MLXSW_SP_REG_MCIA_EEPROM_SIZE);
+
+static inline void mlxsw_reg_mcia_pack(char *payload, u8 module, u8 lock,
+				       u8 page_number, u16 device_addr,
+				       u8 size, u8 i2c_device_addr)
+{
+	MLXSW_REG_ZERO(mcia, payload);
+	mlxsw_reg_mcia_module_set(payload, module);
+	mlxsw_reg_mcia_l_set(payload, lock);
+	mlxsw_reg_mcia_page_number_set(payload, page_number);
+	mlxsw_reg_mcia_device_address_set(payload, device_addr);
+	mlxsw_reg_mcia_size_set(payload, size);
+	mlxsw_reg_mcia_i2c_device_address_set(payload, i2c_device_addr);
+}
+
 /* MPAT - Monitoring Port Analyzer Table
  * -------------------------------------
  * MPAT Register is used to query and configure the Switch PortAnalyzer Table.
@@ -6433,6 +6508,7 @@ static const struct mlxsw_reg_info *mlxsw_reg_infos[] = {
 	MLXSW_REG(mfsl),
 	MLXSW_REG(mtcap),
 	MLXSW_REG(mtmp),
+	MLXSW_REG(mcia),
 	MLXSW_REG(mpat),
 	MLXSW_REG(mpar),
 	MLXSW_REG(mlcr),
-- 
2.9.3
