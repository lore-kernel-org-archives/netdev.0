From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v2 6/7] r8169: fix wake on lan setting for non-8111E
Date: Wed, 6 Jul 2011 15:58:07 +0800
Message-ID: <1309939088-31994-6-git-send-email-hayeswang@realtek.com>
References: <1309939088-31994-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1309939088-31994-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Only 8111E needs enable RxConfig bit 0 ~ 3 when suspending or
shutdowning when supporting wake on lan.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/r8169.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 6bfabe2..8551848 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3390,8 +3390,10 @@ static void r8168_pll_power_down(struct rtl8169_private *tp)
 		rtl_writephy(tp, 0x1f, 0x0000);
 		rtl_writephy(tp, MII_BMCR, 0x0000);
 
-		RTL_W32(RxConfig, RTL_R32(RxConfig) |
-			AcceptBroadcast | AcceptMulticast | AcceptMyPhys);
+		if (tp->mac_version == RTL_GIGA_MAC_VER_32 ||
+		    tp->mac_version == RTL_GIGA_MAC_VER_33)
+			RTL_W32(RxConfig, RTL_R32(RxConfig) | AcceptBroadcast |
+				AcceptMulticast | AcceptMyPhys);
 		return;
 	}
 
-- 
1.7.3.2
