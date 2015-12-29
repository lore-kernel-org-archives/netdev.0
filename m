From: Chunhao Lin <hau@realtek.com>
Subject: [PATCH net-next 1/3] r8169:Fix typo in setting RTL8168EP and RTL8168H D3cold PFM mode
Date: Tue, 29 Dec 2015 22:13:37 +0800
Message-ID: <1451398419-4816-2-git-send-email-hau@realtek.com>
References: <1451398419-4816-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	Chunhao Lin <hau@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1451398419-4816-1-git-send-email-hau@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The register for setting D3code PFM mode is  MISC_1, not DLLPR.

Signed-off-by: Chunhao Lin <hau@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 58365bc..0decc1b 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -6127,7 +6127,7 @@ static void rtl_hw_start_8168h_1(struct rtl8169_private *tp)
 	RTL_W8(EEE_LED, RTL_R8(EEE_LED) & ~0x07);
 
 	RTL_W8(DLLPR, RTL_R8(DLLPR) & ~PFM_EN);
-	RTL_W8(DLLPR, RTL_R8(MISC_1) & ~PFM_D3COLD_EN);
+	RTL_W8(MISC_1, RTL_R8(MISC_1) & ~PFM_D3COLD_EN);
 
 	RTL_W8(DLLPR, RTL_R8(DLLPR) & ~TX_10M_PS_EN);
 
@@ -6252,7 +6252,7 @@ static void rtl_hw_start_8168ep_2(struct rtl8169_private *tp)
 	rtl_hw_start_8168ep(tp);
 
 	RTL_W8(DLLPR, RTL_R8(DLLPR) & ~PFM_EN);
-	RTL_W8(DLLPR, RTL_R8(MISC_1) & ~PFM_D3COLD_EN);
+	RTL_W8(MISC_1, RTL_R8(MISC_1) & ~PFM_D3COLD_EN);
 }
 
 static void rtl_hw_start_8168ep_3(struct rtl8169_private *tp)
@@ -6274,7 +6274,7 @@ static void rtl_hw_start_8168ep_3(struct rtl8169_private *tp)
 	rtl_hw_start_8168ep(tp);
 
 	RTL_W8(DLLPR, RTL_R8(DLLPR) & ~PFM_EN);
-	RTL_W8(DLLPR, RTL_R8(MISC_1) & ~PFM_D3COLD_EN);
+	RTL_W8(MISC_1, RTL_R8(MISC_1) & ~PFM_D3COLD_EN);
 
 	data = r8168_mac_ocp_read(tp, 0xd3e2);
 	data &= 0xf000;
-- 
1.9.1
