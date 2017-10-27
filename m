From: Steve Lin <steven.lin1@broadcom.com>
Subject: [PATCH net-next v4 04/10] devlink: Adding max PF MSI-X vectors perm config param
Date: Fri, 27 Oct 2017 16:54:08 -0400
Message-ID: <1509137654-1580-5-git-send-email-steven.lin1@broadcom.com>
References: <1509137654-1580-1-git-send-email-steven.lin1@broadcom.com>
Cc: jiri@mellanox.com, davem@davemloft.net, michael.chan@broadcom.com,
        linville@tuxdriver.com, gospo@broadcom.com, yuvalm@mellanox.com,
        steven.lin1@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rnd-relay.smtp.broadcom.com ([192.19.229.170]:38538 "EHLO
        rnd-relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932516AbdJ0Uye (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 16:54:34 -0400
In-Reply-To: <1509137654-1580-1-git-send-email-steven.lin1@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding DEVLINK_PERM_CONFIG_MAX_NUM_PF_MSIX_VECT permanent config
parameter.  Value is permanent, so becomes the new default value
for this device.

Value sets the maximum number of PF MSI-X vectors.

Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
Acked-by: Andy Gospodarek <gospo@broadcom.com>
---
 include/uapi/linux/devlink.h | 4 ++++
 net/core/devlink.c           | 1 +
 2 files changed, 5 insertions(+)

diff --git a/include/uapi/linux/devlink.h b/include/uapi/linux/devlink.h
index 2c714fb..2fd0265 100644
--- a/include/uapi/linux/devlink.h
+++ b/include/uapi/linux/devlink.h
@@ -269,10 +269,14 @@ enum devlink_perm_config_enabled {
  * DEVLINK_PERM_CONFIG_NUM_VF_PER_PF: Configures number of total/maximum VFs
  * per PF available on device.
  *   Value: # of VFs per PF in SR-IOV mode
+ * DEVLINK_PERM_CONFIG_NUM_PF_MSIX_VECT: Configures # MSI-X vectors
+ * advertised via PCI capability for this device.
+ *   Value = Max # of MSI-X vectors per PF
  */
 enum devlink_perm_config_param {
 	DEVLINK_PERM_CONFIG_SRIOV_ENABLED,
 	DEVLINK_PERM_CONFIG_NUM_VF_PER_PF,
+	DEVLINK_PERM_CONFIG_NUM_PF_MSIX_VECT,
 
 	__DEVLINK_PERM_CONFIG_MAX,
 	DEVLINK_PERM_CONFIG_MAX = __DEVLINK_PERM_CONFIG_MAX - 1
diff --git a/net/core/devlink.c b/net/core/devlink.c
index 4b1fff3..f970d03 100644
--- a/net/core/devlink.c
+++ b/net/core/devlink.c
@@ -1571,6 +1571,7 @@ static const struct nla_policy devlink_nl_policy[DEVLINK_ATTR_MAX + 1];
 static const u8 devlink_perm_cfg_param_types[DEVLINK_PERM_CONFIG_MAX + 1] = {
 	[DEVLINK_PERM_CONFIG_SRIOV_ENABLED] = NLA_U8,
 	[DEVLINK_PERM_CONFIG_NUM_VF_PER_PF] = NLA_U32,
+	[DEVLINK_PERM_CONFIG_NUM_PF_MSIX_VECT] = NLA_U32,
 };
 
 static int devlink_nl_single_param_get(struct sk_buff *msg,
-- 
2.7.4
