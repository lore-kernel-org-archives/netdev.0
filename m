From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 1/5] r8169: fix the reset setting for 8111evl
Date: Sat, 17 Sep 2011 11:57:03 +0200
Message-ID: <20110917095702.GB21630@electric-eye.fr.zoreil.com>
References: <20110917095617.GA21630@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Hayes Wang <hayeswang@realtek.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:54280 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750949Ab1IQJ5l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2011 05:57:41 -0400
Content-Disposition: inline
In-Reply-To: <20110917095617.GA21630@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rtl8111evl should stop any TLP requirement before resetting by
enabling register 0x37 bit 7.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/r8169.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 02339b3..a1c9070 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3988,6 +3988,7 @@ static void rtl8169_hw_reset(struct rtl8169_private *tp)
 		while (RTL_R8(TxPoll) & NPQ)
 			udelay(20);
 	} else if (tp->mac_version == RTL_GIGA_MAC_VER_34) {
+		RTL_W8(ChipCmd, RTL_R8(ChipCmd) | StopReq);
 		while (!(RTL_R32(TxConfig) & TXCFG_EMPTY))
 			udelay(100);
 	} else {
-- 
1.7.6
