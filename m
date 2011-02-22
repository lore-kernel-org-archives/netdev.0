From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH 3/5] r8169: fix the wrong parameter of point address
Date: Tue, 22 Feb 2011 14:41:55 +0800
Message-ID: <1298356917-486-3-git-send-email-hayeswang@realtek.com>
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

Correct the parameter of rtl8168_oob_notify. It results in the
wrong point address and influences RTL8168DP.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/r8169.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 5d89f89..ff66aa6 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -629,8 +629,9 @@ static void ocp_write(struct rtl8169_private *tp, u8 mask, u16 reg, u32 data)
 	}
 }
 
-static void rtl8168_oob_notify(void __iomem *ioaddr, u8 cmd)
+static void rtl8168_oob_notify(struct rtl8169_private *tp, u8 cmd)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
 	int i;
 
 	RTL_W8(ERIDR, cmd);
@@ -642,7 +643,7 @@ static void rtl8168_oob_notify(void __iomem *ioaddr, u8 cmd)
 			break;
 	}
 
-	ocp_write(ioaddr, 0x1, 0x30, 0x00000001);
+	ocp_write(tp, 0x1, 0x30, 0x00000001);
 }
 
 #define OOB_CMD_RESET		0x00
-- 
1.7.3.2
