From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 13/19] mlxsw: spectrum: Introduce basic set of flexible key blocks
Date: Fri,  3 Feb 2017 10:29:03 +0100
Message-ID: <1486114149-7941-14-git-send-email-jiri@resnulli.us>
References: <1486114149-7941-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com, ogerlitz@mellanox.com, jhs@mojatatu.com,
        ivecera@redhat.com, jbenc@redhat.com, tom@herbertland.com,
        f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36497 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752667AbdBCJ32 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 04:29:28 -0500
Received: by mail-wm0-f68.google.com with SMTP id r18so3090962wmd.3
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 01:29:27 -0800 (PST)
In-Reply-To: <1486114149-7941-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Introduce basic set of Spectrum flexible key blocks. It contains blocks
needed to carry all elements defined so far.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 .../mellanox/mlxsw/spectrum_acl_flex_keys.h        | 109 +++++++++++++++++++++
 1 file changed, 109 insertions(+)
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_flex_keys.h

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_flex_keys.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_flex_keys.h
new file mode 100644
index 0000000..82b81cf
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_flex_keys.h
@@ -0,0 +1,109 @@
+/*
+ * drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_flex_keys.h
+ * Copyright (c) 2017 Mellanox Technologies. All rights reserved.
+ * Copyright (c) 2017 Jiri Pirko <jiri@mellanox.com>
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in the
+ *    documentation and/or other materials provided with the distribution.
+ * 3. Neither the names of the copyright holders nor the names of its
+ *    contributors may be used to endorse or promote products derived from
+ *    this software without specific prior written permission.
+ *
+ * Alternatively, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") version 2 as published by the Free
+ * Software Foundation.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
+ * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
+ * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
+ * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
+ * POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#ifndef _MLXSW_SPECTRUM_ACL_FLEX_KEYS_H
+#define _MLXSW_SPECTRUM_ACL_FLEX_KEYS_H
+
+#include "core_acl_flex_keys.h"
+
+static struct mlxsw_afk_element_inst mlxsw_sp_afk_element_info_l2_dmac[] = {
+	MLXSW_AFK_ELEMENT_INST_BUF(DMAC, 0x00, 6),
+	MLXSW_AFK_ELEMENT_INST_U32(SRC_SYS_PORT, 0x0C, 0, 16),
+};
+
+static struct mlxsw_afk_element_inst mlxsw_sp_afk_element_info_l2_smac[] = {
+	MLXSW_AFK_ELEMENT_INST_BUF(SMAC, 0x00, 6),
+	MLXSW_AFK_ELEMENT_INST_U32(SRC_SYS_PORT, 0x0C, 0, 16),
+};
+
+static struct mlxsw_afk_element_inst mlxsw_sp_afk_element_info_l2_smac_ex[] = {
+	MLXSW_AFK_ELEMENT_INST_BUF(SMAC, 0x02, 6),
+	MLXSW_AFK_ELEMENT_INST_U32(ETHERTYPE, 0x0C, 0, 16),
+};
+
+static struct mlxsw_afk_element_inst mlxsw_sp_afk_element_info_ipv4_sip[] = {
+	MLXSW_AFK_ELEMENT_INST_U32(SRC_IP4, 0x00, 0, 32),
+	MLXSW_AFK_ELEMENT_INST_U32(IP_PROTO, 0x08, 0, 8),
+	MLXSW_AFK_ELEMENT_INST_U32(SRC_SYS_PORT, 0x0C, 0, 16),
+};
+
+static struct mlxsw_afk_element_inst mlxsw_sp_afk_element_info_ipv4_dip[] = {
+	MLXSW_AFK_ELEMENT_INST_U32(DST_IP4, 0x00, 0, 32),
+	MLXSW_AFK_ELEMENT_INST_U32(IP_PROTO, 0x08, 0, 8),
+	MLXSW_AFK_ELEMENT_INST_U32(SRC_SYS_PORT, 0x0C, 0, 16),
+};
+
+static struct mlxsw_afk_element_inst mlxsw_sp_afk_element_info_ipv4_ex[] = {
+	MLXSW_AFK_ELEMENT_INST_U32(SRC_L4_PORT, 0x08, 0, 16),
+	MLXSW_AFK_ELEMENT_INST_U32(DST_L4_PORT, 0x0C, 0, 16),
+};
+
+static struct mlxsw_afk_element_inst mlxsw_sp_afk_element_info_ipv6_dip[] = {
+	MLXSW_AFK_ELEMENT_INST_BUF(DST_IP6_LO, 0x00, 8),
+};
+
+static struct mlxsw_afk_element_inst mlxsw_sp_afk_element_info_ipv6_ex1[] = {
+	MLXSW_AFK_ELEMENT_INST_BUF(DST_IP6_HI, 0x00, 8),
+	MLXSW_AFK_ELEMENT_INST_U32(IP_PROTO, 0x08, 0, 8),
+};
+
+static struct mlxsw_afk_element_inst mlxsw_sp_afk_element_info_ipv6_sip[] = {
+	MLXSW_AFK_ELEMENT_INST_BUF(SRC_IP6_LO, 0x00, 8),
+};
+
+static struct mlxsw_afk_element_inst mlxsw_sp_afk_element_info_ipv6_sip_ex[] = {
+	MLXSW_AFK_ELEMENT_INST_BUF(SRC_IP6_HI, 0x00, 8),
+};
+
+static struct mlxsw_afk_element_inst mlxsw_sp_afk_element_info_packet_type[] = {
+	MLXSW_AFK_ELEMENT_INST_U32(ETHERTYPE, 0x00, 0, 16),
+};
+
+static const struct mlxsw_afk_block mlxsw_sp_afk_blocks[] = {
+	MLXSW_AFK_BLOCK(0x10, mlxsw_sp_afk_element_info_l2_dmac),
+	MLXSW_AFK_BLOCK(0x11, mlxsw_sp_afk_element_info_l2_smac),
+	MLXSW_AFK_BLOCK(0x12, mlxsw_sp_afk_element_info_l2_smac_ex),
+	MLXSW_AFK_BLOCK(0x30, mlxsw_sp_afk_element_info_ipv4_sip),
+	MLXSW_AFK_BLOCK(0x31, mlxsw_sp_afk_element_info_ipv4_dip),
+	MLXSW_AFK_BLOCK(0x33, mlxsw_sp_afk_element_info_ipv4_ex),
+	MLXSW_AFK_BLOCK(0x60, mlxsw_sp_afk_element_info_ipv6_dip),
+	MLXSW_AFK_BLOCK(0x65, mlxsw_sp_afk_element_info_ipv6_ex1),
+	MLXSW_AFK_BLOCK(0x62, mlxsw_sp_afk_element_info_ipv6_sip),
+	MLXSW_AFK_BLOCK(0x63, mlxsw_sp_afk_element_info_ipv6_sip_ex),
+	MLXSW_AFK_BLOCK(0xB0, mlxsw_sp_afk_element_info_packet_type),
+};
+
+#define MLXSW_SP_AFK_BLOCKS_COUNT ARRAY_SIZE(mlxsw_sp_afk_blocks)
+
+#endif
-- 
2.7.4
