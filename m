From: Steve Lin <steven.lin1@broadcom.com>
Subject: [PATCH net-next v3 04/10] devlink: Adding max PF MSI-X vectors perm config param
Date: Tue, 24 Oct 2017 16:12:36 -0400
Message-ID: <1508875962-39233-5-git-send-email-steven.lin1@broadcom.com>
References: <1508875962-39233-1-git-send-email-steven.lin1@broadcom.com>
Cc: jiri@mellanox.com, davem@davemloft.net, michael.chan@broadcom.com,
        linville@tuxdriver.com, gospo@broadcom.com,
        steven.lin1@broadcom.com, yuvalm@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rnd-relay.smtp.broadcom.com ([192.19.229.170]:58356 "EHLO
        rnd-relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751661AbdJXUNq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 16:13:46 -0400
In-Reply-To: <1508875962-39233-1-git-send-email-steven.lin1@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding DEVLINK_PERM_CONFIG_MAX_NUM_PF_MSIX_VECT permanent config
parameter.  Value is permanent, so becomes the new default value
for this device.

Value sets the maximum number of PF MSI-X vectors.

Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
Acked-by: Andy Gospodarek <gospo@broadcom.com>
---
 include/uapi/linux/devlink.h | 3 +++
 net/core/devlink.c           | 1 +
 2 files changed, 4 insertions(+)

diff --git a/include/uapi/linux/devlink.h b/include/uapi/linux/devlink.h
index db512c5..5877ff9 100644
--- a/include/uapi/linux/devlink.h
+++ b/include/uapi/linux/devlink.h
@@ -262,10 +262,13 @@ enum devlink_dpipe_header_id {
  *   1 = enable SR-IOV
  * DEVLINK_PERM_CONFIG_NUM_VF_PER_PF:
  *   # of VFs per PF in SR-IOV mode
+ * DEVLINK_PERM_CONFIG_MAX_NUM_PF_MSIX_VECT:
+ *   Max # of MSI-X vectors per PF
  */
 enum devlink_perm_config_param {
 	DEVLINK_PERM_CONFIG_SRIOV_ENABLED,
 	DEVLINK_PERM_CONFIG_NUM_VF_PER_PF,
+	DEVLINK_PERM_CONFIG_MAX_NUM_PF_MSIX_VECT,
 
 	__DEVLINK_PERM_CONFIG_MAX,
 	DEVLINK_PERM_CONFIG_MAX = __DEVLINK_PERM_CONFIG_MAX - 1
diff --git a/net/core/devlink.c b/net/core/devlink.c
index 18f2600..284e167 100644
--- a/net/core/devlink.c
+++ b/net/core/devlink.c
@@ -1571,6 +1571,7 @@ static const struct nla_policy devlink_nl_policy[DEVLINK_ATTR_MAX + 1];
 static const u8 devlink_perm_cfg_param_types[DEVLINK_PERM_CONFIG_MAX + 1] = {
 	[DEVLINK_PERM_CONFIG_SRIOV_ENABLED] = NLA_U8,
 	[DEVLINK_PERM_CONFIG_NUM_VF_PER_PF] = NLA_U32,
+	[DEVLINK_PERM_CONFIG_MAX_NUM_PF_MSIX_VECT] = NLA_U32,
 };
 
 static int devlink_nl_single_param_get(struct sk_buff *msg,
-- 
2.7.4
