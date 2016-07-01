From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 01/11] bnxt_en: VF/NPAR should return -EOPNOTSUPP for unsupported ethtool ops.
Date: Fri,  1 Jul 2016 18:46:19 -0400
Message-ID: <1467413189-29566-2-git-send-email-michael.chan@broadcom.com>
References: <1467413189-29566-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:32914 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752434AbcGAWqn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 18:46:43 -0400
Received: by mail-pf0-f175.google.com with SMTP id i123so43874438pfg.0
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 15:46:43 -0700 (PDT)
In-Reply-To: <1467413189-29566-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Returning 0 for doing nothing is confusing to the user.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index d7ab2d79..c63ed2f 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -961,7 +961,7 @@ static int bnxt_set_pauseparam(struct net_device *dev,
 	struct bnxt_link_info *link_info = &bp->link_info;
 
 	if (!BNXT_SINGLE_PF(bp))
-		return rc;
+		return -EOPNOTSUPP;
 
 	if (epause->autoneg) {
 		if (!(link_info->autoneg & BNXT_AUTONEG_SPEED))
@@ -1483,7 +1483,7 @@ static int bnxt_set_eee(struct net_device *dev, struct ethtool_eee *edata)
 	int rc = 0;
 
 	if (!BNXT_SINGLE_PF(bp))
-		return 0;
+		return -EOPNOTSUPP;
 
 	if (!(bp->flags & BNXT_FLAG_EEE_CAP))
 		return -EOPNOTSUPP;
-- 
1.8.3.1
