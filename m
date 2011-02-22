From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH 2/3] net/r8169: fix the wrong parameter of point address
Date: Tue, 22 Feb 2011 17:26:20 +0800
Message-ID: <1298366782-1508-3-git-send-email-hayeswang@realtek.com>
References: <1298366782-1508-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:45198 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753103Ab1BVJ2m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 04:28:42 -0500
In-Reply-To: <1298366782-1508-1-git-send-email-hayeswang@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Correct the parameter of rtl8168_oob_notify. It results in the
wrong point address and influences RTL8168DP.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/r8169.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 3630dd7..336ba94 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -617,8 +617,9 @@ static void ocp_write(struct rtl8169_private *tp, u8 mask, u16 reg, u32 data)
 	}
 }
 
-static void rtl8168_oob_notify(void __iomem *ioaddr, u8 cmd)
+static void rtl8168_oob_notify(struct rtl8169_private *tp, u8 cmd)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
 	int i;
 
 	RTL_W8(ERIDR, cmd);
@@ -630,7 +631,7 @@ static void rtl8168_oob_notify(void __iomem *ioaddr, u8 cmd)
 			break;
 	}
 
-	ocp_write(ioaddr, 0x1, 0x30, 0x00000001);
+	ocp_write(tp, 0x1, 0x30, 0x00000001);
 }
 
 #define OOB_CMD_RESET		0x00
-- 
1.7.3.2

