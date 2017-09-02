From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 21/21] mlxsw: reg: Add Routing Tunnel Decap Properties Register
Date: Sat,  2 Sep 2017 17:21:26 +0200
Message-ID: <20170902152126.17286-22-jiri@resnulli.us>
References: <20170902152126.17286-1-jiri@resnulli.us>
Cc: davem@davemloft.net, petrm@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:34859 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752765AbdIBPWC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 2 Sep 2017 11:22:02 -0400
Received: by mail-wr0-f196.google.com with SMTP id a47so1352749wra.2
        for <netdev@vger.kernel.org>; Sat, 02 Sep 2017 08:22:01 -0700 (PDT)
In-Reply-To: <20170902152126.17286-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petr Machata <petrm@mellanox.com>

The RTDP register is used for configuring the tunnel decap properties of
NVE and IPinIP.

Signed-off-by: Petr Machata <petrm@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 129 ++++++++++++++++++++++++++++++
 1 file changed, 129 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 680bc7e..cc27c5d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -5,6 +5,7 @@
  * Copyright (c) 2015 Elad Raz <eladr@mellanox.com>
  * Copyright (c) 2015-2017 Jiri Pirko <jiri@mellanox.com>
  * Copyright (c) 2016 Yotam Gigi <yotamg@mellanox.com>
+ * Copyright (c) 2017 Petr Machata <petrm@mellanox.com>
  *
  * Redistribution and use in source and binary forms, with or without
  * modification, are permitted provided that the following conditions are met:
@@ -5468,6 +5469,133 @@ static inline void mlxsw_reg_rauhtd_ent_ipv6_unpack(char *payload,
 	mlxsw_reg_rauhtd_ipv6_ent_dip_memcpy_from(payload, rec_index, p_dip);
 }
 
+/* RTDP - Routing Tunnel Decap Properties Register
+ * -----------------------------------------------
+ * The RTDP register is used for configuring the tunnel decap properties of NVE
+ * and IPinIP.
+ */
+#define MLXSW_REG_RTDP_ID 0x8020
+#define MLXSW_REG_RTDP_LEN 0x44
+
+MLXSW_REG_DEFINE(rtdp, MLXSW_REG_RTDP_ID, MLXSW_REG_RTDP_LEN);
+
+enum mlxsw_reg_rtdp_type {
+	MLXSW_REG_RTDP_TYPE_NVE,
+	MLXSW_REG_RTDP_TYPE_IPIP,
+};
+
+/* reg_rtdp_type
+ * Type of the RTDP entry as per enum mlxsw_reg_rtdp_type.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, rtdp, type, 0x00, 28, 4);
+
+/* reg_rtdp_tunnel_index
+ * Index to the Decap entry.
+ * For Spectrum, Index to KVD Linear.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, rtdp, tunnel_index, 0x00, 0, 24);
+
+/* IPinIP */
+
+/* reg_rtdp_ipip_irif
+ * Ingress Router Interface for the overlay router
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, rtdp, ipip_irif, 0x04, 16, 16);
+
+enum mlxsw_reg_rtdp_ipip_sip_check {
+	/* No sip checks. */
+	MLXSW_REG_RTDP_IPIP_SIP_CHECK_NO,
+	/* Filter packet if underlay is not IPv4 or if underlay SIP does not
+	 * equal ipv4_usip.
+	 */
+	MLXSW_REG_RTDP_IPIP_SIP_CHECK_FILTER_IPV4,
+	/* Filter packet if underlay is not IPv6 or if underlay SIP does not
+	 * equal ipv6_usip.
+	 */
+	MLXSW_REG_RTDP_IPIP_SIP_CHECK_FILTER_IPV6 = 3,
+};
+
+/* reg_rtdp_ipip_sip_check
+ * SIP check to perform. If decapsulation failed due to these configurations
+ * then trap_id is IPIP_DECAP_ERROR.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, rtdp, ipip_sip_check, 0x04, 0, 3);
+
+/* If set, allow decapsulation of IPinIP (without GRE). */
+#define MLXSW_REG_RTDP_IPIP_TYPE_CHECK_ALLOW_IPIP	BIT(0)
+/* If set, allow decapsulation of IPinGREinIP without a key. */
+#define MLXSW_REG_RTDP_IPIP_TYPE_CHECK_ALLOW_GRE	BIT(1)
+/* If set, allow decapsulation of IPinGREinIP with a key. */
+#define MLXSW_REG_RTDP_IPIP_TYPE_CHECK_ALLOW_GRE_KEY	BIT(2)
+
+/* reg_rtdp_ipip_type_check
+ * Flags as per MLXSW_REG_RTDP_IPIP_TYPE_CHECK_*. If decapsulation failed due to
+ * these configurations then trap_id is IPIP_DECAP_ERROR.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, rtdp, ipip_type_check, 0x08, 24, 3);
+
+/* reg_rtdp_ipip_gre_key_check
+ * Whether GRE key should be checked. When check is enabled:
+ * - A packet received as IPinIP (without GRE) will always pass.
+ * - A packet received as IPinGREinIP without a key will not pass the check.
+ * - A packet received as IPinGREinIP with a key will pass the check only if the
+ *   key in the packet is equal to expected_gre_key.
+ * If decapsulation failed due to GRE key then trap_id is IPIP_DECAP_ERROR.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, rtdp, ipip_gre_key_check, 0x08, 23, 1);
+
+/* reg_rtdp_ipip_ipv4_usip
+ * Underlay IPv4 address for ipv4 source address check.
+ * Reserved when sip_check is not '1'.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, rtdp, ipip_ipv4_usip, 0x0C, 0, 32);
+
+/* reg_rtdp_ipip_ipv6_usip_ptr
+ * This field is valid when sip_check is "sipv6 check explicitly". This is a
+ * pointer to the IPv6 DIP which is configured by RIPS. For Spectrum, the index
+ * is to the KVD linear.
+ * Reserved when sip_check is not MLXSW_REG_RTDP_IPIP_SIP_CHECK_FILTER_IPV6.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, rtdp, ipip_ipv6_usip_ptr, 0x10, 0, 24);
+
+/* reg_rtdp_ipip_expected_gre_key
+ * GRE key for checking.
+ * Reserved when gre_key_check is '0'.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, rtdp, ipip_expected_gre_key, 0x14, 0, 32);
+
+static inline void mlxsw_reg_rtdp_pack(char *payload,
+				       enum mlxsw_reg_rtdp_type type,
+				       u32 tunnel_index)
+{
+	MLXSW_REG_ZERO(rtdp, payload);
+	mlxsw_reg_rtdp_type_set(payload, type);
+	mlxsw_reg_rtdp_tunnel_index_set(payload, tunnel_index);
+}
+
+static inline void
+mlxsw_reg_rtdp_ipip4_pack(char *payload, u16 irif,
+			  enum mlxsw_reg_rtdp_ipip_sip_check sip_check,
+			  unsigned int type_check, bool gre_key_check,
+			  u32 ipv4_usip, u32 expected_gre_key)
+{
+	mlxsw_reg_rtdp_ipip_irif_set(payload, irif);
+	mlxsw_reg_rtdp_ipip_sip_check_set(payload, sip_check);
+	mlxsw_reg_rtdp_ipip_type_check_set(payload, type_check);
+	mlxsw_reg_rtdp_ipip_gre_key_check_set(payload, gre_key_check);
+	mlxsw_reg_rtdp_ipip_ipv4_usip_set(payload, ipv4_usip);
+	mlxsw_reg_rtdp_ipip_expected_gre_key_set(payload, expected_gre_key);
+}
+
 /* MFCR - Management Fan Control Register
  * --------------------------------------
  * This register controls the settings of the Fan Speed PWM mechanism.
@@ -6729,6 +6857,7 @@ static const struct mlxsw_reg_info *mlxsw_reg_infos[] = {
 	MLXSW_REG(rgcr),
 	MLXSW_REG(ritr),
 	MLXSW_REG(ratr),
+	MLXSW_REG(rtdp),
 	MLXSW_REG(ricnt),
 	MLXSW_REG(ralta),
 	MLXSW_REG(ralst),
-- 
2.9.3
