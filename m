From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH 4/5] r8169: adjust the code of RTL8168DP
Date: Tue, 22 Feb 2011 14:41:56 +0800
Message-ID: <1298356917-486-4-git-send-email-hayeswang@realtek.com>
References: <1298356917-486-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1298356917-486-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adjust the code of power up and down functions for RTL8168DP.
Skip these functions when DASH is enable.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/r8169.c |   17 ++++++++++++++---
 1 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index ff66aa6..9e7e3b3 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2917,8 +2917,11 @@ static void r8168_pll_power_down(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
 
-	if (tp->mac_version == RTL_GIGA_MAC_VER_27)
+	if (((tp->mac_version == RTL_GIGA_MAC_VER_27) ||
+	     (tp->mac_version == RTL_GIGA_MAC_VER_28)) &&
+	    (ocp_read(tp, 0x0f, 0x0010) & 0x00008000)) {
 		return;
+	}
 
 	if (((tp->mac_version == RTL_GIGA_MAC_VER_23) ||
 	     (tp->mac_version == RTL_GIGA_MAC_VER_24)) &&
@@ -2940,6 +2943,8 @@ static void r8168_pll_power_down(struct rtl8169_private *tp)
 	switch (tp->mac_version) {
 	case RTL_GIGA_MAC_VER_25:
 	case RTL_GIGA_MAC_VER_26:
+	case RTL_GIGA_MAC_VER_27:
+	case RTL_GIGA_MAC_VER_28:
 		RTL_W8(PMCH, RTL_R8(PMCH) & ~0x80);
 		break;
 	}
@@ -2949,12 +2954,17 @@ static void r8168_pll_power_up(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
 
-	if (tp->mac_version == RTL_GIGA_MAC_VER_27)
+	if (((tp->mac_version == RTL_GIGA_MAC_VER_27) ||
+	     (tp->mac_version == RTL_GIGA_MAC_VER_28)) &&
+	    (ocp_read(tp, 0x0f, 0x0010) & 0x00008000)) {
 		return;
+	}
 
 	switch (tp->mac_version) {
 	case RTL_GIGA_MAC_VER_25:
 	case RTL_GIGA_MAC_VER_26:
+	case RTL_GIGA_MAC_VER_27:
+	case RTL_GIGA_MAC_VER_28:
 		RTL_W8(PMCH, RTL_R8(PMCH) | 0x80);
 		break;
 	}
@@ -3369,7 +3379,8 @@ static void rtl8169_hw_reset(struct rtl8169_private *tp)
 	/* Disable interrupts */
 	rtl8169_irq_mask_and_ack(ioaddr);
 
-	if (tp->mac_version == RTL_GIGA_MAC_VER_28) {
+	if (tp->mac_version == RTL_GIGA_MAC_VER_27 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_28) {
 		while (RTL_R8(TxPoll) & NPQ)
 			udelay(20);
 
-- 
1.7.3.2
