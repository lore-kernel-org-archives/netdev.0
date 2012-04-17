From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 2/7] r8169: 8168c and later require bit 0x20 to be set in Config2 for PME signaling.
Date: Tue, 17 Apr 2012 12:59:36 +0200
Message-ID: <d387b427c973974dd619a33549c070ac5d0e089f.1334660032.git.romieu@fr.zoreil.com>
References: <1334660032.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>,
	Hayes Wang <hayeswang@realtek.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:37857 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754551Ab2DQLE0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Apr 2012 07:04:26 -0400
In-Reply-To: <1334660032.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new 84xx stopped flying below the radars.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 9b0b00b..207aadc 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -315,6 +315,8 @@ enum rtl_registers {
 	Config0		= 0x51,
 	Config1		= 0x52,
 	Config2		= 0x53,
+#define PME_SIGNAL			(1 << 5)	/* 8168c and later */
+
 	Config3		= 0x54,
 	Config4		= 0x55,
 	Config5		= 0x56,
@@ -1422,6 +1424,10 @@ static void __rtl8169_set_wol(struct rtl8169_private *tp, u32 wolopts)
 		RTL_W8(Config1, options);
 		break;
 	default:
+		options = RTL_R8(Config2) & ~PME_SIGNAL;
+		if (wolopts)
+			options |= PME_SIGNAL;
+		RTL_W8(Config2, options);
 		break;
 	}
 
-- 
1.7.7.6
