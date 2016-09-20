From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v2 09/10] bnxt_en: Support for "ethtool -r" command
Date: Tue, 20 Sep 2016 02:50:27 -0400
Message-ID: <1474354228-3221-10-git-send-email-michael.chan@broadcom.com>
References: <1474354228-3221-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org,
        Deepak Khungar <deepak.khungar@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:33332 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753048AbcITGup (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 02:50:45 -0400
Received: by mail-pf0-f179.google.com with SMTP id 21so4111832pfy.0
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 23:50:45 -0700 (PDT)
In-Reply-To: <1474354228-3221-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Deepak Khungar <deepak.khungar@broadcom.com>

Restart autoneg if autoneg is enabled.

Signed-off-by: Deepak Khungar <deepak.khungar@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index de893c9..0ee4d7b 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -1849,6 +1849,25 @@ static int bnxt_get_module_eeprom(struct net_device *dev,
 	return rc;
 }
 
+static int bnxt_nway_reset(struct net_device *dev)
+{
+	int rc = 0;
+
+	struct bnxt *bp = netdev_priv(dev);
+	struct bnxt_link_info *link_info = &bp->link_info;
+
+	if (!BNXT_SINGLE_PF(bp))
+		return -EOPNOTSUPP;
+
+	if (!(link_info->autoneg & BNXT_AUTONEG_SPEED))
+		return -EINVAL;
+
+	if (netif_running(dev))
+		rc = bnxt_hwrm_set_link_setting(bp, true, false);
+
+	return rc;
+}
+
 const struct ethtool_ops bnxt_ethtool_ops = {
 	.get_link_ksettings	= bnxt_get_link_ksettings,
 	.set_link_ksettings	= bnxt_set_link_ksettings,
@@ -1881,4 +1900,5 @@ const struct ethtool_ops bnxt_ethtool_ops = {
 	.set_eee		= bnxt_set_eee,
 	.get_module_info	= bnxt_get_module_info,
 	.get_module_eeprom	= bnxt_get_module_eeprom,
+	.nway_reset		= bnxt_nway_reset
 };
-- 
1.8.3.1
