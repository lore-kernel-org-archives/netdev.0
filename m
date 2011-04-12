From: Borislav Petkov <bp@amd64.org>
Subject: [PATCH] r8169: Be verbose when unable to load fw patch
Date: Tue, 12 Apr 2011 15:32:52 +0200
Message-ID: <1302615172-1646-1-git-send-email-bp@amd64.org>
Cc: <linux-kernel@vger.kernel.org>,
	Borislav Petkov <borislav.petkov@amd.com>,
	netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Borislav Petkov <borislav.petkov@amd.com>

When the driver fails loading the firmware, it doesn't say which patch
exactly it is missing. We have three different firmware images depending
on the hw revision, so mention the exact patch name it is unable to load
in the warning message.

Cc: Francois Romieu <romieu@fr.zoreil.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Borislav Petkov <borislav.petkov@amd.com>
---
 drivers/net/r8169.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 493b0de..b068115 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2248,7 +2248,7 @@ static void rtl8168d_1_hw_phy_config(struct rtl8169_private *tp)
 	rtl_writephy(tp, 0x05, 0x001b);
 	if ((rtl_readphy(tp, 0x06) != 0xbf00) ||
 	    (rtl_apply_firmware(tp, FIRMWARE_8168D_1) < 0)) {
-		netif_warn(tp, probe, tp->dev, "unable to apply firmware patch\n");
+		netif_warn(tp, probe, tp->dev, "unable to apply firmware patch %s\n", FIRMWARE_8168D_1);
 	}
 
 	rtl_writephy(tp, 0x1f, 0x0000);
@@ -2353,7 +2353,7 @@ static void rtl8168d_2_hw_phy_config(struct rtl8169_private *tp)
 	rtl_writephy(tp, 0x05, 0x001b);
 	if ((rtl_readphy(tp, 0x06) != 0xb300) ||
 	    (rtl_apply_firmware(tp, FIRMWARE_8168D_2) < 0)) {
-		netif_warn(tp, probe, tp->dev, "unable to apply firmware patch\n");
+		netif_warn(tp, probe, tp->dev, "unable to apply firmware patch %s\n", FIRMWARE_8168D_2);
 	}
 
 	rtl_writephy(tp, 0x1f, 0x0000);
@@ -2475,7 +2475,7 @@ static void rtl8105e_hw_phy_config(struct rtl8169_private *tp)
 	msleep(100);
 
 	if (rtl_apply_firmware(tp, FIRMWARE_8105E_1) < 0)
-		netif_warn(tp, probe, tp->dev, "unable to apply firmware patch\n");
+		netif_warn(tp, probe, tp->dev, "unable to apply firmware patch %s\n", FIRMWARE_8105E_1);
 
 	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 }
-- 
1.7.4
