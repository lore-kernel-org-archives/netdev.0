From: Steve Lin <steven.lin1@broadcom.com>
Subject: [PATCH 2/7] devlink: Adding NPAR permanent config parameters
Date: Tue, 17 Oct 2017 16:44:24 -0400
Message-ID: <1508273069-40461-3-git-send-email-steven.lin1@broadcom.com>
References: <1508273069-40461-1-git-send-email-steven.lin1@broadcom.com>
Cc: jiri@mellanox.com, davem@davemloft.net, michael.chan@broadcom.com,
        linville@tuxdriver.com, gospo@broadcom.com,
        steven.lin1@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rnd-relay.smtp.broadcom.com ([192.19.229.170]:49920 "EHLO
        rnd-relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1760623AbdJQUop (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 16:44:45 -0400
In-Reply-To: <1508273069-40461-1-git-send-email-steven.lin1@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extending DEVLINK_ATTR_PERM_CFG (permanent/NVRAM device configuration)
to include NPAR settings:

DEVLINK_ATTR_PERM_CFG_NPAR_NUM_PARTITIONS_PER_PORT: Number of NIC
Partitions (NPAR) per port.

DEVLINK_ATTR_PERM_CFG_NPAR_BW_IN_PERCENT: 1 if BW_RESERVATION and
BW_LIMIT is in percent; /0 if BW_RESERVATION and BW_LIMIT is in
100 Mbps units.

DEVLINK_ATTR_PERM_CFG_NPAR_BW_RESERVATION: Configures NPAR bandwidth
or weight reservation, in percent or 100 Mbps units, depending on
BW_IN_PERCENT.

DEVLINK_ATTR_PERM_CFG_NPAR_BW_RESERVATION_VALID: 1 to use
BW_RESERVATION setting, 0 to ignore.

DEVLINK_ATTR_PERM_CFG_NPAR_BW_LIMIT: Configures NPAR bandwidth or
weight limit, in percent or 100 Mbps units, depending on
BW_IN_PERCENT.

DEVLINK_ATTR_PERM_CFG_NPAR_BW_LIMIT_VALID: 1 to use BW_LIMIT
setting, 0 to ignore.

Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
Acked-by: Andy Gospodarek <gospo@broadcom.com>
---
 include/uapi/linux/devlink.h | 8 +++++++-
 net/core/devlink.c           | 7 +++++++
 2 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/devlink.h b/include/uapi/linux/devlink.h
index 34de44d..21cfb37 100644
--- a/include/uapi/linux/devlink.h
+++ b/include/uapi/linux/devlink.h
@@ -218,9 +218,15 @@ enum devlink_attr {
 	DEVLINK_ATTR_PERM_CFG_NUM_VF_PER_PF,		/* u32 */
 	DEVLINK_ATTR_PERM_CFG_MAX_NUM_PF_MSIX_VECT,	/* u32 */
 	DEVLINK_ATTR_PERM_CFG_MSIX_VECTORS_PER_VF,	/* u32 */
+	DEVLINK_ATTR_PERM_CFG_NPAR_NUM_PARTITIONS_PER_PORT,	/* u32 */
+	DEVLINK_ATTR_PERM_CFG_NPAR_BW_IN_PERCENT,	/* u32 */
+	DEVLINK_ATTR_PERM_CFG_NPAR_BW_RESERVATION,	/* u32 */
+	DEVLINK_ATTR_PERM_CFG_NPAR_BW_RESERVATION_VALID,/* u8 */
+	DEVLINK_ATTR_PERM_CFG_NPAR_BW_LIMIT,		/* u32 */
+	DEVLINK_ATTR_PERM_CFG_NPAR_BW_LIMIT_VALID,	/* u8 */
 
 	/* Add new permanent config parameters above here */
-	DEVLINK_ATTR_PERM_CFG_LAST = DEVLINK_ATTR_PERM_CFG_MSIX_VECTORS_PER_VF,
+	DEVLINK_ATTR_PERM_CFG_LAST = DEVLINK_ATTR_PERM_CFG_NPAR_BW_LIMIT_VALID,
 
 	/* add new attributes above here, update the policy in devlink.c */
 
diff --git a/net/core/devlink.c b/net/core/devlink.c
index 427a65e..76bb6d4 100644
--- a/net/core/devlink.c
+++ b/net/core/devlink.c
@@ -2543,6 +2543,13 @@ static const struct nla_policy devlink_nl_policy[DEVLINK_ATTR_MAX + 1] = {
 	[DEVLINK_ATTR_PERM_CFG_NUM_VF_PER_PF] = { .type = NLA_U32 },
 	[DEVLINK_ATTR_PERM_CFG_MAX_NUM_PF_MSIX_VECT] = { .type = NLA_U32 },
 	[DEVLINK_ATTR_PERM_CFG_MSIX_VECTORS_PER_VF] = { .type = NLA_U32 },
+	[DEVLINK_ATTR_PERM_CFG_NPAR_NUM_PARTITIONS_PER_PORT] = {
+		.type = NLA_U32 },
+	[DEVLINK_ATTR_PERM_CFG_NPAR_BW_IN_PERCENT] = { .type = NLA_U32 },
+	[DEVLINK_ATTR_PERM_CFG_NPAR_BW_RESERVATION] = { .type = NLA_U32 },
+	[DEVLINK_ATTR_PERM_CFG_NPAR_BW_RESERVATION_VALID] = { .type = NLA_U8 },
+	[DEVLINK_ATTR_PERM_CFG_NPAR_BW_LIMIT] = { .type = NLA_U32 },
+	[DEVLINK_ATTR_PERM_CFG_NPAR_BW_LIMIT_VALID] = { .type = NLA_U8 },
 };
 
 static const struct genl_ops devlink_nl_ops[] = {
-- 
2.7.4
