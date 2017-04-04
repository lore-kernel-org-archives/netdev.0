From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 04/12] bnxt_en: Add ethtool get_wol method.
Date: Tue,  4 Apr 2017 18:14:09 -0400
Message-ID: <1491344057-12663-5-git-send-email-michael.chan@broadcom.com>
References: <1491344057-12663-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:35518 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755144AbdDDWOn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 18:14:43 -0400
Received: by mail-wm0-f53.google.com with SMTP id y22so36450641wmh.0
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 15:14:42 -0700 (PDT)
In-Reply-To: <1491344057-12663-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 16 ++++++++++++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.h |  1 +
 2 files changed, 17 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index 6903a87..2b94704 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -1,6 +1,7 @@
 /* Broadcom NetXtreme-C/E network driver.
  *
  * Copyright (c) 2014-2016 Broadcom Corporation
+ * Copyright (c) 2016-2017 Broadcom Limited
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -832,6 +833,20 @@ static void bnxt_get_drvinfo(struct net_device *dev,
 	kfree(pkglog);
 }
 
+static void bnxt_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+{
+	struct bnxt *bp = netdev_priv(dev);
+
+	wol->supported = 0;
+	wol->wolopts = 0;
+	memset(&wol->sopass, 0, sizeof(wol->sopass));
+	if (bp->flags & BNXT_FLAG_WOL_CAP) {
+		wol->supported = WAKE_MAGIC;
+		if (bp->wol)
+			wol->wolopts = WAKE_MAGIC;
+	}
+}
+
 u32 _bnxt_fw_to_ethtool_adv_spds(u16 fw_speeds, u8 fw_pause)
 {
 	u32 speed_mask = 0;
@@ -2134,6 +2149,7 @@ static int bnxt_set_phys_id(struct net_device *dev,
 	.get_pauseparam		= bnxt_get_pauseparam,
 	.set_pauseparam		= bnxt_set_pauseparam,
 	.get_drvinfo		= bnxt_get_drvinfo,
+	.get_wol		= bnxt_get_wol,
 	.get_coalesce		= bnxt_get_coalesce,
 	.set_coalesce		= bnxt_set_coalesce,
 	.get_msglevel		= bnxt_get_msglevel,
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.h b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.h
index ed1e555..2762171 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.h
@@ -1,6 +1,7 @@
 /* Broadcom NetXtreme-C/E network driver.
  *
  * Copyright (c) 2014-2016 Broadcom Corporation
+ * Copyright (c) 2016-2017 Broadcom Limited
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
-- 
1.8.3.1
