From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 06/14] r8152: clear BMCR_PDOWN
Date: Tue, 18 Feb 2014 21:49:03 +0800
Message-ID: <1392731351-25502-7-git-send-email-hayeswang@realtek.com>
References: <1392731351-25502-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392731351-25502-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Modify the method of enabling the PHY to clear BMCR_PDOWN only.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 2a778fa..c7bae39 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1845,7 +1845,14 @@ static inline void r8152b_enable_aldps(struct r8152 *tp)
 
 static void r8152b_hw_phy_cfg(struct r8152 *tp)
 {
-	r8152_mdio_write(tp, MII_BMCR, BMCR_ANENABLE);
+	u16 data;
+
+	data = r8152_mdio_read(tp, MII_BMCR);
+	if (data & BMCR_PDOWN) {
+		data &= ~BMCR_PDOWN;
+		r8152_mdio_write(tp, MII_BMCR, data);
+	}
+
 	r8152b_disable_aldps(tp);
 }
 
@@ -1995,7 +2002,11 @@ static void r8153_hw_phy_cfg(struct r8152 *tp)
 	u16 data;
 
 	ocp_reg_write(tp, OCP_ADC_CFG, CKADSEL_L | ADC_EN | EN_EMI_L);
-	r8152_mdio_write(tp, MII_BMCR, BMCR_ANENABLE);
+	data = r8152_mdio_read(tp, MII_BMCR);
+	if (data & BMCR_PDOWN) {
+		data &= ~BMCR_PDOWN;
+		r8152_mdio_write(tp, MII_BMCR, data);
+	}
 
 	if (tp->version == RTL_VER_03) {
 		data = ocp_reg_read(tp, OCP_EEE_CFG);
-- 
1.8.4.2
