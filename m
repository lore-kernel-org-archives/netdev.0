From: Himanshu Jha <himanshujha199640@gmail.com>
Subject: [PATCH v2] at76c50x-usb: check memory allocation failure
Date: Wed, 23 Aug 2017 19:59:16 +0530
Message-ID: <1503498556-13835-1-git-send-email-himanshujha199640@gmail.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        Himanshu Jha <himanshujha199640@gmail.com>
To: kvalo@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35191 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932146AbdHWO3n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 10:29:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check memory allocation failure and return -ENOMEM rather than just
retuning void.

Signed-off-by: Himanshu Jha <himanshujha199640@gmail.com>
---
 drivers/net/wireless/atmel/at76c50x-usb.c | 28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/wireless/atmel/at76c50x-usb.c b/drivers/net/wireless/atmel/at76c50x-usb.c
index 09defbc..ceb453b 100644
--- a/drivers/net/wireless/atmel/at76c50x-usb.c
+++ b/drivers/net/wireless/atmel/at76c50x-usb.c
@@ -932,7 +932,7 @@ static int at76_set_autorate_fallback(struct at76_priv *priv, int onoff)
 	return ret;
 }
 
-static void at76_dump_mib_mac_addr(struct at76_priv *priv)
+static int at76_dump_mib_mac_addr(struct at76_priv *priv)
 {
 	int i;
 	int ret;
@@ -940,7 +940,7 @@ static void at76_dump_mib_mac_addr(struct at76_priv *priv)
 					 GFP_KERNEL);
 
 	if (!m)
-		return;
+		return -ENOMEM;
 
 	ret = at76_get_mib(priv->udev, MIB_MAC_ADDR, m,
 			   sizeof(struct mib_mac_addr));
@@ -961,7 +961,7 @@ static void at76_dump_mib_mac_addr(struct at76_priv *priv)
 	kfree(m);
 }
 
-static void at76_dump_mib_mac_wep(struct at76_priv *priv)
+static int at76_dump_mib_mac_wep(struct at76_priv *priv)
 {
 	int i;
 	int ret;
@@ -969,7 +969,7 @@ static void at76_dump_mib_mac_wep(struct at76_priv *priv)
 	struct mib_mac_wep *m = kmalloc(sizeof(struct mib_mac_wep), GFP_KERNEL);
 
 	if (!m)
-		return;
+		return -ENOMEM;
 
 	ret = at76_get_mib(priv->udev, MIB_MAC_WEP, m,
 			   sizeof(struct mib_mac_wep));
@@ -999,14 +999,14 @@ static void at76_dump_mib_mac_wep(struct at76_priv *priv)
 	kfree(m);
 }
 
-static void at76_dump_mib_mac_mgmt(struct at76_priv *priv)
+static int at76_dump_mib_mac_mgmt(struct at76_priv *priv)
 {
 	int ret;
 	struct mib_mac_mgmt *m = kmalloc(sizeof(struct mib_mac_mgmt),
 					 GFP_KERNEL);
 
 	if (!m)
-		return;
+		return -ENOMEM;
 
 	ret = at76_get_mib(priv->udev, MIB_MAC_MGMT, m,
 			   sizeof(struct mib_mac_mgmt));
@@ -1037,13 +1037,13 @@ static void at76_dump_mib_mac_mgmt(struct at76_priv *priv)
 	kfree(m);
 }
 
-static void at76_dump_mib_mac(struct at76_priv *priv)
+static int at76_dump_mib_mac(struct at76_priv *priv)
 {
 	int ret;
 	struct mib_mac *m = kmalloc(sizeof(struct mib_mac), GFP_KERNEL);
 
 	if (!m)
-		return;
+		return -ENOMEM;
 
 	ret = at76_get_mib(priv->udev, MIB_MAC, m, sizeof(struct mib_mac));
 	if (ret < 0) {
@@ -1074,13 +1074,13 @@ static void at76_dump_mib_mac(struct at76_priv *priv)
 	kfree(m);
 }
 
-static void at76_dump_mib_phy(struct at76_priv *priv)
+static int at76_dump_mib_phy(struct at76_priv *priv)
 {
 	int ret;
 	struct mib_phy *m = kmalloc(sizeof(struct mib_phy), GFP_KERNEL);
 
 	if (!m)
-		return;
+		return -ENOMEM;
 
 	ret = at76_get_mib(priv->udev, MIB_PHY, m, sizeof(struct mib_phy));
 	if (ret < 0) {
@@ -1107,13 +1107,13 @@ static void at76_dump_mib_phy(struct at76_priv *priv)
 	kfree(m);
 }
 
-static void at76_dump_mib_local(struct at76_priv *priv)
+static int at76_dump_mib_local(struct at76_priv *priv)
 {
 	int ret;
 	struct mib_local *m = kmalloc(sizeof(*m), GFP_KERNEL);
 
 	if (!m)
-		return;
+		return -ENOMEM;
 
 	ret = at76_get_mib(priv->udev, MIB_LOCAL, m, sizeof(*m));
 	if (ret < 0) {
@@ -1132,13 +1132,13 @@ static void at76_dump_mib_local(struct at76_priv *priv)
 	kfree(m);
 }
 
-static void at76_dump_mib_mdomain(struct at76_priv *priv)
+static int at76_dump_mib_mdomain(struct at76_priv *priv)
 {
 	int ret;
 	struct mib_mdomain *m = kmalloc(sizeof(struct mib_mdomain), GFP_KERNEL);
 
 	if (!m)
-		return;
+		return -ENOMEM;
 
 	ret = at76_get_mib(priv->udev, MIB_MDOMAIN, m,
 			   sizeof(struct mib_mdomain));
-- 
2.7.4
