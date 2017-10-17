From: Steve Lin <steven.lin1@broadcom.com>
Subject: [PATCH 3/7] devlink: Adding high level dev perm config params
Date: Tue, 17 Oct 2017 16:44:25 -0400
Message-ID: <1508273069-40461-4-git-send-email-steven.lin1@broadcom.com>
References: <1508273069-40461-1-git-send-email-steven.lin1@broadcom.com>
Cc: jiri@mellanox.com, davem@davemloft.net, michael.chan@broadcom.com,
        linville@tuxdriver.com, gospo@broadcom.com,
        steven.lin1@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rnd-relay.smtp.broadcom.com ([192.19.229.170]:49926 "EHLO
        rnd-relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1760629AbdJQUoq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 16:44:46 -0400
In-Reply-To: <1508273069-40461-1-git-send-email-steven.lin1@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extending DEVLINK_ATTR_PERM_CFG (permanent/NVRAM device configuration)
to include some high level device configuration settings:

DEVLINK_ATTR_PERM_CFG_DCBX_MODE: Data Center Bridging Exchange
(DCBX) protocol mode; use enum devlink_dcbx_mode.

DEVLINK_ATTR_PERM_CFG_RDMA_ENABLED: 1 to enable RDMA, 0 to disable.

DEVLINK_ATTR_PERM_CFG_MULTIFUNC_MODE: Configure multi-function
mode; use devlink_multifunc_mode.

DEVLINK_ATTR_PERM_CFG_SECURE_NIC_ENABLED: 1 to enable Secure NIC
functionality, 0 to disable.

DEVLINK_ATTR_PERM_CFG_IGNORE_ARI_CAPABILITY: 1 to ignore ARI
(Alternate Routing ID) interpretation, 0 to honor ARI.

DEVLINK_ATTR_PERM_CFG_LLDP_NEAREST_BRIDGE_ENABLED: 1 to enable
Link Layer Data Protocol (LLDP) on Nearest Bridge, 0 to
disable.

DEVLINK_ATTR_PERM_CFG_LLDP_NEAREST_NONTPMR_BRIDGE_ENABLED: 1 to
enable Link Layer Data Protocol (LLDP) on Non Two Port MAC
Relay (non-TPMR) Bridge, 0 to disable.

DEVLINK_ATTR_PERM_CFG_PME_CAPABILITY_ENABLED: 1 to enable Power
Management Events (PME) functionality, 0 to disable.

DEVLINK_ATTR_PERM_CFG_MAGIC_PACKET_WOL_ENABLED: 1 to enable
Magic Packet Wake on Lan using ACPI pattern, 0 to disable.

DEVLINK_ATTR_PERM_CFG_EEE_PWR_SAVE_ENABLED: 1 to enable Energy
Efficient Ethernet (EEE), 0 to disable.

Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
Acked-by: Andy Gospodarek <gospo@broadcom.com>
---
 include/uapi/linux/devlink.h | 27 ++++++++++++++++++++++++++-
 net/core/devlink.c           | 12 ++++++++++++
 2 files changed, 38 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/devlink.h b/include/uapi/linux/devlink.h
index 21cfb37..4a9eafd 100644
--- a/include/uapi/linux/devlink.h
+++ b/include/uapi/linux/devlink.h
@@ -127,6 +127,21 @@ enum devlink_eswitch_encap_mode {
 	DEVLINK_ESWITCH_ENCAP_MODE_BASIC,
 };
 
+enum devlink_dcbx_mode {
+	DEVLINK_DCBX_MODE_DISABLED,
+	DEVLINK_DCBX_MODE_IEEE,
+	DEVLINK_DCBX_MODE_CEE,
+	DEVLINK_DCBX_MODE_IEEE_CEE,
+};
+
+enum devlink_multifunc_mode {
+	DEVLINK_MULTIFUNC_MODE_ALLOWED,		/* Ext switch activates MF */
+	DEVLINK_MULTIFUNC_MODE_FORCE_SINGFUNC,
+	DEVLINK_MULTIFUNC_MODE_NPAR10,		/* NPAR 1.0 */
+	DEVLINK_MULTIFUNC_MODE_NPAR15,		/* NPAR 1.5 */
+	DEVLINK_MULTIFUNC_MODE_NPAR20,		/* NPAR 2.0 */
+};
+
 enum devlink_attr {
 	/* don't change the order or add anything between, this is ABI! */
 	DEVLINK_ATTR_UNSPEC,
@@ -224,9 +239,19 @@ enum devlink_attr {
 	DEVLINK_ATTR_PERM_CFG_NPAR_BW_RESERVATION_VALID,/* u8 */
 	DEVLINK_ATTR_PERM_CFG_NPAR_BW_LIMIT,		/* u32 */
 	DEVLINK_ATTR_PERM_CFG_NPAR_BW_LIMIT_VALID,	/* u8 */
+	DEVLINK_ATTR_PERM_CFG_DCBX_MODE,		/* u32 */
+	DEVLINK_ATTR_PERM_CFG_RDMA_ENABLED,		/* u8 */
+	DEVLINK_ATTR_PERM_CFG_MULTIFUNC_MODE,		/* u32 */
+	DEVLINK_ATTR_PERM_CFG_SECURE_NIC_ENABLED,	/* u8 */
+	DEVLINK_ATTR_PERM_CFG_IGNORE_ARI_CAPABILITY,	/* u8 */
+	DEVLINK_ATTR_PERM_CFG_LLDP_NEAREST_BRIDGE_ENABLED,	/* u8 */
+	DEVLINK_ATTR_PERM_CFG_LLDP_NEAREST_NONTPMR_BRIDGE_ENABLED,	/* u8 */
+	DEVLINK_ATTR_PERM_CFG_PME_CAPABILITY_ENABLED,	/* u8 */
+	DEVLINK_ATTR_PERM_CFG_MAGIC_PACKET_WOL_ENABLED,	/* u8 */
+	DEVLINK_ATTR_PERM_CFG_EEE_PWR_SAVE_ENABLED,	/* u8 */
 
 	/* Add new permanent config parameters above here */
-	DEVLINK_ATTR_PERM_CFG_LAST = DEVLINK_ATTR_PERM_CFG_NPAR_BW_LIMIT_VALID,
+	DEVLINK_ATTR_PERM_CFG_LAST = DEVLINK_ATTR_PERM_CFG_EEE_PWR_SAVE_ENABLED,
 
 	/* add new attributes above here, update the policy in devlink.c */
 
diff --git a/net/core/devlink.c b/net/core/devlink.c
index 76bb6d4..d611154 100644
--- a/net/core/devlink.c
+++ b/net/core/devlink.c
@@ -2550,6 +2550,18 @@ static const struct nla_policy devlink_nl_policy[DEVLINK_ATTR_MAX + 1] = {
 	[DEVLINK_ATTR_PERM_CFG_NPAR_BW_RESERVATION_VALID] = { .type = NLA_U8 },
 	[DEVLINK_ATTR_PERM_CFG_NPAR_BW_LIMIT] = { .type = NLA_U32 },
 	[DEVLINK_ATTR_PERM_CFG_NPAR_BW_LIMIT_VALID] = { .type = NLA_U8 },
+	[DEVLINK_ATTR_PERM_CFG_DCBX_MODE] = { .type = NLA_U32 },
+	[DEVLINK_ATTR_PERM_CFG_RDMA_ENABLED] = { .type = NLA_U8 },
+	[DEVLINK_ATTR_PERM_CFG_MULTIFUNC_MODE] = { .type = NLA_U32 },
+	[DEVLINK_ATTR_PERM_CFG_SECURE_NIC_ENABLED] = { .type = NLA_U8 },
+	[DEVLINK_ATTR_PERM_CFG_IGNORE_ARI_CAPABILITY] = { .type = NLA_U8 },
+	[DEVLINK_ATTR_PERM_CFG_LLDP_NEAREST_BRIDGE_ENABLED] = {
+		.type = NLA_U8 },
+	[DEVLINK_ATTR_PERM_CFG_LLDP_NEAREST_NONTPMR_BRIDGE_ENABLED] = {
+		.type = NLA_U8 },
+	[DEVLINK_ATTR_PERM_CFG_PME_CAPABILITY_ENABLED] = { .type = NLA_U8 },
+	[DEVLINK_ATTR_PERM_CFG_MAGIC_PACKET_WOL_ENABLED] = { .type = NLA_U8 },
+	[DEVLINK_ATTR_PERM_CFG_EEE_PWR_SAVE_ENABLED] = { .type = NLA_U8 },
 };
 
 static const struct genl_ops devlink_nl_ops[] = {
-- 
2.7.4
