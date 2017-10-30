From: Steve Lin <steven.lin1@broadcom.com>
Subject: [PATCH net-next v5 05/10] devlink: Adding num MSI-X vectors per VF perm config param
Date: Mon, 30 Oct 2017 10:46:11 -0400
Message-ID: <1509374776-45869-6-git-send-email-steven.lin1@broadcom.com>
References: <1509374776-45869-1-git-send-email-steven.lin1@broadcom.com>
Cc: jiri@mellanox.com, davem@davemloft.net, michael.chan@broadcom.com,
        linville@tuxdriver.com, gospo@broadcom.com, yuvalm@mellanox.com,
        steven.lin1@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rnd-relay.smtp.broadcom.com ([192.19.229.170]:51678 "EHLO
        rnd-relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751941AbdJ3Oqa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 10:46:30 -0400
In-Reply-To: <1509374776-45869-1-git-send-email-steven.lin1@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding DEVLINK_PERM_CONFIG_NUM_MSIX_VECT_PER_VF permanent config
parameter. Value is permanent, so becomes the new default value
for this device.

Value defines number of MSI-X vectors allocated per VF.

Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
Acked-by: Andy Gospodarek <gospo@broadcom.com>
---
 include/uapi/linux/devlink.h | 4 ++++
 net/core/devlink.c           | 1 +
 2 files changed, 5 insertions(+)

diff --git a/include/uapi/linux/devlink.h b/include/uapi/linux/devlink.h
index 6936c0e..fe56a02 100644
--- a/include/uapi/linux/devlink.h
+++ b/include/uapi/linux/devlink.h
@@ -276,11 +276,15 @@ enum devlink_perm_config_enabled {
  * DEVLINK_PERM_CONFIG_NUM_PF_MSIX_VECT: Configures the # of MSI-X vectors
  * advertised via PCI capability for this device.
  *   Value = Max # of MSI-X vectors per PF
+ * DEVLINK_PERM_CONFIG_NUM_MSIX_VECT_PER_VF: Configures the # of MSI-X vectors
+ * advertised via PCI capability for each VF on this device.
+ *   # of MSI-X vectors per VF
  */
 enum devlink_perm_config_param {
 	DEVLINK_PERM_CONFIG_SRIOV_ENABLED,
 	DEVLINK_PERM_CONFIG_NUM_VF_PER_PF,
 	DEVLINK_PERM_CONFIG_NUM_PF_MSIX_VECT,
+	DEVLINK_PERM_CONFIG_NUM_MSIX_VECT_PER_VF,
 
 	__DEVLINK_PERM_CONFIG_MAX,
 	DEVLINK_PERM_CONFIG_MAX = __DEVLINK_PERM_CONFIG_MAX - 1
diff --git a/net/core/devlink.c b/net/core/devlink.c
index 78bb949..f1f16c2 100644
--- a/net/core/devlink.c
+++ b/net/core/devlink.c
@@ -1572,6 +1572,7 @@ static const u8 devlink_perm_cfg_param_types[DEVLINK_PERM_CONFIG_MAX + 1] = {
 	[DEVLINK_PERM_CONFIG_SRIOV_ENABLED] = NLA_U8,
 	[DEVLINK_PERM_CONFIG_NUM_VF_PER_PF] = NLA_U32,
 	[DEVLINK_PERM_CONFIG_NUM_PF_MSIX_VECT] = NLA_U32,
+	[DEVLINK_PERM_CONFIG_NUM_MSIX_VECT_PER_VF] = NLA_U32,
 };
 
 static int devlink_nl_single_param_get(struct sk_buff *msg,
-- 
2.7.4
