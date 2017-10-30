From: Steve Lin <steven.lin1@broadcom.com>
Subject: [PATCH net-next v5 02/10] devlink: Adding SR-IOV enablement perm config param
Date: Mon, 30 Oct 2017 10:46:08 -0400
Message-ID: <1509374776-45869-3-git-send-email-steven.lin1@broadcom.com>
References: <1509374776-45869-1-git-send-email-steven.lin1@broadcom.com>
Cc: jiri@mellanox.com, davem@davemloft.net, michael.chan@broadcom.com,
        linville@tuxdriver.com, gospo@broadcom.com, yuvalm@mellanox.com,
        steven.lin1@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rnd-relay.smtp.broadcom.com ([192.19.229.170]:51655 "EHLO
        rnd-relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751886AbdJ3Oq3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 10:46:29 -0400
In-Reply-To: <1509374776-45869-1-git-send-email-steven.lin1@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding DEVLINK_PERM_CONFIG_SRIOV_ENABLED permanent config
parameter; this parameter controls whether the device
advertises the SR-IOV PCI capability. Value is permanent, so
becomes the new default value for this device.

  DEVLINK_PERM_CONFIG_DISABLE = Disable SR-IOV
  DEVLINK_PERM_CONFIG_ENABLE  = Enable SR-IOV

Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
Acked-by: Andy Gospodarek <gospo@broadcom.com>
---
 include/uapi/linux/devlink.h | 18 +++++++++++++++++-
 net/core/devlink.c           |  1 +
 2 files changed, 18 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/devlink.h b/include/uapi/linux/devlink.h
index 55e35f2..1c5d4ae 100644
--- a/include/uapi/linux/devlink.h
+++ b/include/uapi/linux/devlink.h
@@ -256,8 +256,24 @@ enum devlink_dpipe_header_id {
 	DEVLINK_DPIPE_HEADER_IPV6,
 };
 
-/* Permanent config parameters */
+/* Permanent config parameter enable/disable
+ * DEVLINK_PERM_CONFIG_DISABLE = disable a permanent config parameter
+ * DEVLINK_PERM_CONFIG_ENBALE  = enable a permanent config parameter
+ */
+enum devlink_perm_config_enabled {
+	DEVLINK_PERM_CONFIG_DISABLE,
+	DEVLINK_PERM_CONFIG_ENABLE,
+};
+
+/* Permanent config parameters:
+ * DEVLINK_PERM_CONFIG_SRIOV_ENABLED: Configures whether SR-IOV PCI capability
+ * is advertised by the device.
+ *   DEVLINK_PERM_CONFIG_DISABLE = disable SR-IOV
+ *   DEVLINK_PERM_CONFIG_ENABLE  = enable SR-IOV
+ */
 enum devlink_perm_config_param {
+	DEVLINK_PERM_CONFIG_SRIOV_ENABLED,
+
 	__DEVLINK_PERM_CONFIG_MAX,
 	DEVLINK_PERM_CONFIG_MAX = __DEVLINK_PERM_CONFIG_MAX - 1
 };
diff --git a/net/core/devlink.c b/net/core/devlink.c
index 5e77408..b4d43c29 100644
--- a/net/core/devlink.c
+++ b/net/core/devlink.c
@@ -1569,6 +1569,7 @@ static int devlink_nl_cmd_eswitch_set_doit(struct sk_buff *skb,
 static const struct nla_policy devlink_nl_policy[DEVLINK_ATTR_MAX + 1];
 
 static const u8 devlink_perm_cfg_param_types[DEVLINK_PERM_CONFIG_MAX + 1] = {
+	[DEVLINK_PERM_CONFIG_SRIOV_ENABLED] = NLA_U8,
 };
 
 static int devlink_nl_single_param_get(struct sk_buff *msg,
-- 
2.7.4
