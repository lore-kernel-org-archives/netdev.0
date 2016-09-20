From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net 5/5] r8152: disable ALDPS and EEE before setting PHY
Date: Tue, 20 Sep 2016 16:22:09 +0800
Message-ID: <1394712342-15778-224-Taiwan-albertk@realtek.com>
References: <1394712342-15778-219-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394712342-15778-219-Taiwan-albertk-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Disable ALDPS and EEE to avoid the possible failure when setting the PHY.

Signed-off-by: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/usb/r8152.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index e7a05dd..3c3cdb4 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -32,7 +32,7 @@
 #define NETNEXT_VERSION		"08"
 
 /* Information for net */
-#define NET_VERSION		"5"
+#define NET_VERSION		"6"
 
 #define DRIVER_VERSION		"v1." NETNEXT_VERSION "." NET_VERSION
 #define DRIVER_AUTHOR "Realtek linux nic maintainers <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>"
@@ -2808,6 +2808,13 @@ static void r8153_hw_phy_cfg(struct r8152 *tp)
 	u32 ocp_data;
 	u16 data;
 
+	/* disable ALDPS before updating the PHY parameters */
+	r8153_aldps_en(tp, false);
+
+	/* disable EEE before updating the PHY parameters */
+	r8153_eee_en(tp, false);
+	ocp_reg_write(tp, OCP_EEE_ADV, 0);
+
 	if (tp->version == RTL_VER_03) {
 		data = ocp_reg_read(tp, OCP_EEE_CFG);
 		data &= ~CTAP_SHORT_EN;
@@ -3390,7 +3397,6 @@ static void r8153_init(struct r8152 *tp)
 	if (test_bit(RTL8152_UNPLUG, &tp->flags))
 		return;
 
-	r8153_aldps_en(tp, false);
 	r8153_u1u2en(tp, false);
 
 	for (i = 0; i < 500; i++) {
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
