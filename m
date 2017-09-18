From: Sathya Perla <sathya.perla@broadcom.com>
Subject: [net PATCH] bnxt_en: check for ingress qdisc in flower offload
Date: Mon, 18 Sep 2017 17:05:37 +0530
Message-ID: <1505734537-6695-1-git-send-email-sathya.perla@broadcom.com>
Cc: michael.chan@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lpdvsmtp01.broadcom.com ([192.19.211.62]:39097 "EHLO
        relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754035AbdIRLkw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 07:40:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check for ingress-only qdisc for flower offload, as other qdiscs
are not supported for flower offload.

Suggested-by: Jiri Pirko <jiri@resnulli.us>
Signed-off-by: Sathya Perla <sathya.perla@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c
index ccd699f..7dd3d13 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c
@@ -750,6 +750,10 @@ int bnxt_tc_setup_flower(struct bnxt *bp, u16 src_fid,
 {
 	int rc = 0;
 
+	if (!is_classid_clsact_ingress(cls_flower->common.classid) ||
+	    cls_flower->common.chain_index)
+		return -EOPNOTSUPP;
+
 	switch (cls_flower->command) {
 	case TC_CLSFLOWER_REPLACE:
 		rc = bnxt_tc_add_flow(bp, src_fid, cls_flower);
-- 
2.7.4
