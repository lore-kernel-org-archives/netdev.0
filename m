From: Steve Lin <steven.lin1@broadcom.com>
Subject: [PATCH net-next v5 03/10] devlink: Adding num VFs per PF permanent config param
Date: Mon, 30 Oct 2017 10:46:09 -0400
Message-ID: <1509374776-45869-4-git-send-email-steven.lin1@broadcom.com>
References: <1509374776-45869-1-git-send-email-steven.lin1@broadcom.com>
Cc: jiri@mellanox.com, davem@davemloft.net, michael.chan@broadcom.com,
        linville@tuxdriver.com, gospo@broadcom.com, yuvalm@mellanox.com,
        steven.lin1@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rnd-relay.smtp.broadcom.com ([192.19.229.170]:51658 "EHLO
        rnd-relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751750AbdJ3Oq3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 10:46:29 -0400
In-Reply-To: <1509374776-45869-1-git-send-email-steven.lin1@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding DEVLINK_PERM_CONFIG_NUM_VF_PER_PF permanent config
parameter. Value is permanent, so becomes the new default
value for this device.

The value sets the number of VFs per PF in SR-IOV mode.

Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
Acked-by: Andy Gospodarek <gospo@broadcom.com>
---
 include/uapi/linux/devlink.h | 4 ++++
 net/core/devlink.c           | 1 +
 2 files changed, 5 insertions(+)

diff --git a/include/uapi/linux/devlink.h b/include/uapi/linux/devlink.h
index 1c5d4ae..4e0b8b7 100644
--- a/include/uapi/linux/devlink.h
+++ b/include/uapi/linux/devlink.h
@@ -270,9 +270,13 @@ enum devlink_perm_config_enabled {
  * is advertised by the device.
  *   DEVLINK_PERM_CONFIG_DISABLE = disable SR-IOV
  *   DEVLINK_PERM_CONFIG_ENABLE  = enable SR-IOV
+ * DEVLINK_PERM_CONFIG_NUM_VF_PER_PF: Configures the number of total/maximum
+ * VFs per PF available on device.
+ *   Value: # of VFs per PF in SR-IOV mode
  */
 enum devlink_perm_config_param {
 	DEVLINK_PERM_CONFIG_SRIOV_ENABLED,
+	DEVLINK_PERM_CONFIG_NUM_VF_PER_PF,
 
 	__DEVLINK_PERM_CONFIG_MAX,
 	DEVLINK_PERM_CONFIG_MAX = __DEVLINK_PERM_CONFIG_MAX - 1
diff --git a/net/core/devlink.c b/net/core/devlink.c
index b4d43c29..f421cfb 100644
--- a/net/core/devlink.c
+++ b/net/core/devlink.c
@@ -1570,6 +1570,7 @@ static const struct nla_policy devlink_nl_policy[DEVLINK_ATTR_MAX + 1];
 
 static const u8 devlink_perm_cfg_param_types[DEVLINK_PERM_CONFIG_MAX + 1] = {
 	[DEVLINK_PERM_CONFIG_SRIOV_ENABLED] = NLA_U8,
+	[DEVLINK_PERM_CONFIG_NUM_VF_PER_PF] = NLA_U32,
 };
 
 static int devlink_nl_single_param_get(struct sk_buff *msg,
-- 
2.7.4
