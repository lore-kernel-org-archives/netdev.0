From: Chunhao Lin <hau@realtek.com>
Subject: [PATCH net-next] r8169:fix system hange problem.
Date: Fri, 5 Feb 2016 02:28:00 +0800
Message-ID: <1454610480-3274-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	Chunhao Lin <hau@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:43309 "EHLO
	rtits2.realtek.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932182AbcBDSoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 13:44:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are typos in setting RTL8168H hardware parameters. If system install
another version driver that may cuase system hang.

Signed-off-by: Chunhao Lin <hau@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 17d5571..537974c 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -6137,28 +6137,28 @@ static void rtl_hw_start_8168h_1(struct rtl8169_private *tp)
 		sw_cnt_1ms_ini = 16000000/rg_saw_cnt;
 		sw_cnt_1ms_ini &= 0x0fff;
 		data = r8168_mac_ocp_read(tp, 0xd412);
-		data &= 0x0fff;
+		data &= ~0x0fff;
 		data |= sw_cnt_1ms_ini;
 		r8168_mac_ocp_write(tp, 0xd412, data);
 	}
 
 	data = r8168_mac_ocp_read(tp, 0xe056);
-	data &= 0xf0;
-	data |= 0x07;
+	data &= ~0xf0;
+	data |= 0x70;
 	r8168_mac_ocp_write(tp, 0xe056, data);
 
 	data = r8168_mac_ocp_read(tp, 0xe052);
-	data &= 0x8008;
-	data |= 0x6000;
+	data &= ~0x6000;
+	data |= 0x8008;
 	r8168_mac_ocp_write(tp, 0xe052, data);
 
 	data = r8168_mac_ocp_read(tp, 0xe0d6);
-	data &= 0x01ff;
+	data &= ~0x01ff;
 	data |= 0x017f;
 	r8168_mac_ocp_write(tp, 0xe0d6, data);
 
 	data = r8168_mac_ocp_read(tp, 0xd420);
-	data &= 0x0fff;
+	data &= ~0x0fff;
 	data |= 0x047f;
 	r8168_mac_ocp_write(tp, 0xd420, data);
 
-- 
1.9.1
