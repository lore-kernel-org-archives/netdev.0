From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v5 3/5] r8169: fix the reset setting for 8111evl
Date: Tue, 6 Sep 2011 16:55:16 +0800
Message-ID: <1315299318-1547-3-git-send-email-hayeswang@realtek.com>
References: <1315299318-1547-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:39276 "EHLO
	rtits2.realtek.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753296Ab1IFIzf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2011 04:55:35 -0400
In-Reply-To: <1315299318-1547-1-git-send-email-hayeswang@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rtl8111evl should stop any TLP requirement before resetting by
enabling register 0x37 bit 7.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index db5ab2c..175c769 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -3997,6 +3997,7 @@ static void rtl8169_hw_reset(struct rtl8169_private *tp)
 		while (RTL_R8(TxPoll) & NPQ)
 			udelay(20);
 	} else if (tp->mac_version == RTL_GIGA_MAC_VER_34) {
+		RTL_W8(ChipCmd, RTL_R8(ChipCmd) | StopReq);
 		while (!(RTL_R32(TxConfig) & TXCFG_EMPTY))
 			udelay(100);
 	} else {
-- 
1.7.6
