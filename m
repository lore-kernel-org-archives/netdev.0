From: Zhu Yanjun <yanjun.zhu@oracle.com>
Subject: [PATCH 1/1] r8169: replace init_timer with setup_timer
Date: Sun, 12 Mar 2017 05:02:54 -0400
Message-ID: <1489309374-1979-1-git-send-email-yanjun.zhu@oracle.com>
To: nic_swsd@realtek.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:46635 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755303AbdCLJDc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 05:03:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace init_timer with setup_timer to simplify the source code.

Signed-off-by: Zhu Yanjun <yanjun.zhu@oracle.com>
---
 drivers/net/ethernet/realtek/r8169.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 81f18a8..44cc422 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -8444,9 +8444,7 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	tp->opts1_mask = (tp->mac_version != RTL_GIGA_MAC_VER_01) ?
 		~(RxBOVF | RxFOVF) : ~0;
 
-	init_timer(&tp->timer);
-	tp->timer.data = (unsigned long) dev;
-	tp->timer.function = rtl8169_phy_timer;
+	setup_timer(&tp->timer, rtl8169_phy_timer, (unsigned long)dev);
 
 	tp->rtl_fw = RTL_FIRMWARE_UNKNOWN;
 
-- 
2.7.4
