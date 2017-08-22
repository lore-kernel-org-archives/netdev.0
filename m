From: Himanshu Jha <himanshujha199640@gmail.com>
Subject: [PATCH] drivers: net: wireless: atmel: check memory allocation failure
Date: Tue, 22 Aug 2017 13:41:21 +0530
Message-ID: <1503389481-4988-1-git-send-email-himanshujha199640@gmail.com>
Cc: linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, Himanshu Jha <himanshujha199640@gmail.com>
To: kvalo@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Check memory allocation failure and return -ENOMEM if failure
occurs.

Signed-off-by: Himanshu Jha <himanshujha199640@gmail.com>
---
 drivers/net/wireless/atmel/at76c50x-usb.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/wireless/atmel/at76c50x-usb.c b/drivers/net/wireless/atmel/at76c50x-usb.c
index 09defbc..73f0924 100644
--- a/drivers/net/wireless/atmel/at76c50x-usb.c
+++ b/drivers/net/wireless/atmel/at76c50x-usb.c
@@ -940,7 +940,7 @@ static void at76_dump_mib_mac_addr(struct at76_priv *priv)
 					 GFP_KERNEL);
 
 	if (!m)
-		return;
+		return -ENOMEM;
 
 	ret = at76_get_mib(priv->udev, MIB_MAC_ADDR, m,
 			   sizeof(struct mib_mac_addr));
@@ -969,7 +969,7 @@ static void at76_dump_mib_mac_wep(struct at76_priv *priv)
 	struct mib_mac_wep *m = kmalloc(sizeof(struct mib_mac_wep), GFP_KERNEL);
 
 	if (!m)
-		return;
+		return -ENOMEM;
 
 	ret = at76_get_mib(priv->udev, MIB_MAC_WEP, m,
 			   sizeof(struct mib_mac_wep));
@@ -1006,7 +1006,7 @@ static void at76_dump_mib_mac_mgmt(struct at76_priv *priv)
 					 GFP_KERNEL);
 
 	if (!m)
-		return;
+		return -ENOMEM;
 
 	ret = at76_get_mib(priv->udev, MIB_MAC_MGMT, m,
 			   sizeof(struct mib_mac_mgmt));
@@ -1043,7 +1043,7 @@ static void at76_dump_mib_mac(struct at76_priv *priv)
 	struct mib_mac *m = kmalloc(sizeof(struct mib_mac), GFP_KERNEL);
 
 	if (!m)
-		return;
+		return -ENOMEM;
 
 	ret = at76_get_mib(priv->udev, MIB_MAC, m, sizeof(struct mib_mac));
 	if (ret < 0) {
@@ -1080,7 +1080,7 @@ static void at76_dump_mib_phy(struct at76_priv *priv)
 	struct mib_phy *m = kmalloc(sizeof(struct mib_phy), GFP_KERNEL);
 
 	if (!m)
-		return;
+		return -ENOMEM;
 
 	ret = at76_get_mib(priv->udev, MIB_PHY, m, sizeof(struct mib_phy));
 	if (ret < 0) {
@@ -1113,7 +1113,7 @@ static void at76_dump_mib_local(struct at76_priv *priv)
 	struct mib_local *m = kmalloc(sizeof(*m), GFP_KERNEL);
 
 	if (!m)
-		return;
+		return -ENOMEM;
 
 	ret = at76_get_mib(priv->udev, MIB_LOCAL, m, sizeof(*m));
 	if (ret < 0) {
@@ -1138,7 +1138,7 @@ static void at76_dump_mib_mdomain(struct at76_priv *priv)
 	struct mib_mdomain *m = kmalloc(sizeof(struct mib_mdomain), GFP_KERNEL);
 
 	if (!m)
-		return;
+		return -ENOMEM;
 
 	ret = at76_get_mib(priv->udev, MIB_MDOMAIN, m,
 			   sizeof(struct mib_mdomain));
-- 
2.7.4
