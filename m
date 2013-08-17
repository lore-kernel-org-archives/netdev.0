From: Peter Wu <lekensteyn@gmail.com>
Subject: [PATCH] r8169: remember WOL preferences on driver load
Date: Sat, 17 Aug 2013 11:00:02 +0200
Message-ID: <1376730002-9235-1-git-send-email-lekensteyn@gmail.com>
Cc: nic_swsd <nic_swsd@realtek.com>,
	Hayes Wang <hayeswang@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>, lekensteyn@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:36552 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752177Ab3HQJAI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Aug 2013 05:00:08 -0400
Received: by mail-ee0-f54.google.com with SMTP id e53so1271781eek.41
        for <netdev@vger.kernel.org>; Sat, 17 Aug 2013 02:00:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Wu <lekensteyn@gmail.com>

Do not clear Broadcast/Multicast/Unicast Wake Flag or LanWake in
Config5. This is necessary to preserve WOL state when the driver is
loaded. Although the r8168 vendor driver does not write Config5 (it has
been commented out), Hayes Wang from Realtek said that masking bits like
this is more sensible.

Signed-off-by: Peter Wu <lekensteyn@gmail.com>
---
 drivers/net/ethernet/realtek/r8169.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 2943916..104eaef 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -7092,7 +7092,7 @@ rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
 	RTL_W8(Config1, RTL_R8(Config1) | PMEnable);
-	RTL_W8(Config5, RTL_R8(Config5) & PMEStatus);
+	RTL_W8(Config5, RTL_R8(Config5) & (BWF | MWF | UWF | LanWake | PMEStatus));
 	if ((RTL_R8(Config3) & (LinkUp | MagicPacket)) != 0)
 		tp->features |= RTL_FEATURE_WOL;
 	if ((RTL_R8(Config5) & (UWF | BWF | MWF)) != 0)
-- 
1.8.3.4
