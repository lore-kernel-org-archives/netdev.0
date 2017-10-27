From: Steve Lin <steven.lin1@broadcom.com>
Subject: [PATCH net-next v4 05/10] devlink: Adding num MSI-X vectors per VF perm config param
Date: Fri, 27 Oct 2017 16:54:09 -0400
Message-ID: <1509137654-1580-6-git-send-email-steven.lin1@broadcom.com>
References: <1509137654-1580-1-git-send-email-steven.lin1@broadcom.com>
Cc: jiri@mellanox.com, davem@davemloft.net, michael.chan@broadcom.com,
        linville@tuxdriver.com, gospo@broadcom.com, yuvalm@mellanox.com,
        steven.lin1@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rnd-relay.smtp.broadcom.com ([192.19.229.170]:38556 "EHLO
        rnd-relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932574AbdJ0Uyf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 16:54:35 -0400
In-Reply-To: <1509137654-1580-1-git-send-email-steven.lin1@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding DEVLINK_PERM_CONFIG_NUM_MSIX_VECT_PER_VF permanent config
parameter.  Value is permanent, so becomes the new default value
for this device.

Value defines number of MSI-X vectors allocated per VF.

Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
Acked-by: Andy Gospodarek <gospo@broadcom.com>
---
 include/uapi/linux/devlink.h | 4 ++++
 net/core/devlink.c           | 1 +
 2 files changed, 5 insertions(+)

diff --git a/include/uapi/linux/devlink.h b/include/uapi/linux/devlink.h
index 2fd0265..50000a0 100644
--- a/include/uapi/linux/devlink.h
+++ b/include/uapi/linux/devlink.h
@@ -272,11 +272,15 @@ enum devlink_perm_config_enabled {
  * DEVLINK_PERM_CONFIG_NUM_PF_MSIX_VECT: Configures # MSI-X vectors
  * advertised via PCI capability for this device.
  *   Value = Max # of MSI-X vectors per PF
+ * DEVLINK_PERM_CONFIG_NUM_MSIX_VECT_PER_VF: Configures # MSI-X vectors
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
index f970d03..226d151 100644
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
