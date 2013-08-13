From: Peter Wu <lekensteyn@gmail.com>
Subject: [PATCH] r8169: remember WOL preferences on driver load
Date: Tue, 13 Aug 2013 22:19:05 +0200
Message-ID: <1376425145-30142-1-git-send-email-lekensteyn@gmail.com>
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com, lekensteyn@gmail.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:59745 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758679Ab3HMUTM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 16:19:12 -0400
Received: by mail-wi0-f182.google.com with SMTP id hi8so1126301wib.9
        for <netdev@vger.kernel.org>; Tue, 13 Aug 2013 13:19:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do not clear Broadcast/Multicast/Unicast Wake Flag or LanWake in
Config5. This is necessary to preserve WOL state when the driver is
loaded. The r8168 vendor driver used to write to both Config1 and
Config5, but in recent versions, this is commented out. Here we keep
writing PMEnable to Config1 because there may be older chips where
PMEnable is not sticky.

Signed-off-by: Peter Wu <lekensteyn@gmail.com>
---
 drivers/net/ethernet/realtek/r8169.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 28af01c..7bdf322 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -7093,7 +7093,6 @@ rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
 	RTL_W8(Config1, RTL_R8(Config1) | PMEnable);
-	RTL_W8(Config5, RTL_R8(Config5) & PMEStatus);
 	if ((RTL_R8(Config3) & (LinkUp | MagicPacket)) != 0)
 		tp->features |= RTL_FEATURE_WOL;
 	if ((RTL_R8(Config5) & (UWF | BWF | MWF)) != 0)
-- 
1.8.3.4
