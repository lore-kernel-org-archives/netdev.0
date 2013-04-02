From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH v2 net-next 3/8] r8169: Update PHY settings of RTL8111G
Date: Tue, 2 Apr 2013 16:23:37 +0800
Message-ID: <1364891022-3220-3-git-send-email-hayeswang@realtek.com>
References: <1364824539-4156-1-git-send-email-hayeswang@realtek.com>
 <1364891022-3220-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1364891022-3220-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add the new settings and correct the wrong settings.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 24 ++++++++++++++++++++++--
 1 file changed, 22 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 2c40309..b8b59a9 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -3376,14 +3376,23 @@ static void rtl8168g_1_hw_phy_config(struct rtl8169_private *tp)
 		rtl_writephy(tp, 0x1f, 0x0c41);
 		rtl_w1w0_phy(tp, 0x15, 0x0002, 0x0000);
 	} else {
-		rtl_writephy(tp, 0x1f, 0x0bcc);
-		rtl_w1w0_phy(tp, 0x12, 0x0000, 0x0002);
+		rtl_writephy(tp, 0x1f, 0x0c41);
+		rtl_w1w0_phy(tp, 0x15, 0x0000, 0x0002);
 	}
 
 	/* Enable PHY auto speed down */
 	rtl_writephy(tp, 0x1f, 0x0a44);
 	rtl_w1w0_phy(tp, 0x11, 0x000c, 0x0000);
 
+	rtl_writephy(tp, 0x1f, 0x0bcc);
+	rtl_w1w0_phy(tp, 0x14, 0x0100, 0x0000);
+	rtl_writephy(tp, 0x1f, 0x0a44);
+	rtl_w1w0_phy(tp, 0x11, 0x00c0, 0x0000);
+	rtl_writephy(tp, 0x1f, 0x0a43);
+	rtl_writephy(tp, 0x13, 0x8084);
+	rtl_w1w0_phy(tp, 0x14, 0x0000, 0x6000);
+	rtl_w1w0_phy(tp, 0x10, 0x1003, 0x0000);
+
 	/* EEE auto-fallback function */
 	rtl_writephy(tp, 0x1f, 0x0a4b);
 	rtl_w1w0_phy(tp, 0x11, 0x0004, 0x0000);
@@ -3396,6 +3405,17 @@ static void rtl8168g_1_hw_phy_config(struct rtl8169_private *tp)
 	rtl_writephy(tp, 0x1f, 0x0c42);
 	rtl_w1w0_phy(tp, 0x11, 0x4000, 0x2000);
 
+	/* Improve SWR Efficiency */
+	rtl_writephy(tp, 0x1f, 0x0bcd);
+	rtl_writephy(tp, 0x14, 0x5065);
+	rtl_writephy(tp, 0x14, 0xd065);
+	rtl_writephy(tp, 0x1f, 0x0bc8);
+	rtl_writephy(tp, 0x11, 0x5655);
+	rtl_writephy(tp, 0x1f, 0x0bcd);
+	rtl_writephy(tp, 0x14, 0x1065);
+	rtl_writephy(tp, 0x14, 0x9065);
+	rtl_writephy(tp, 0x14, 0x1065);
+
 	rtl_writephy(tp, 0x1f, 0x0000);
 }
 
-- 
1.8.1
