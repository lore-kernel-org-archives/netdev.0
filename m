From: Adam Borowski <kilobyte@angband.pl>
Subject: [PATCH] rtl8xxxu: Don't printk raw binary if serial number is not burned in.
Date: Fri,  8 Sep 2017 01:51:03 +0200
Message-ID: <20170907235103.5359-1-kilobyte@angband.pl>
Cc: Adam Borowski <kilobyte@angband.pl>
To: Jes Sorensen <Jes.Sorensen@gmail.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tartarus.angband.pl ([89.206.35.136]:50888 "EHLO
        tartarus.angband.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750966AbdIGXvQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 19:51:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I assume that a blank efuse comes with all ones, thus I did not bother
recognizing other possible junk values.  This matches 100% of dongles
I've seen (a single Gembird 8192eu).

Signed-off-by: Adam Borowski <kilobyte@angband.pl>
---
 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c
index 80fee699f58a..bdc37e7272ca 100644
--- a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c
+++ b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c
@@ -614,7 +614,11 @@ static int rtl8192eu_parse_efuse(struct rtl8xxxu_priv *priv)
 
 	dev_info(&priv->udev->dev, "Vendor: %.7s\n", efuse->vendor_name);
 	dev_info(&priv->udev->dev, "Product: %.11s\n", efuse->device_name);
-	dev_info(&priv->udev->dev, "Serial: %.11s\n", efuse->serial);
+	if (strncmp(efuse->serial,
+		    "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff", 11))
+		dev_info(&priv->udev->dev, "Serial: %.11s\n", efuse->serial);
+	else
+		dev_info(&priv->udev->dev, "Serial not available.\n");
 
 	if (rtl8xxxu_debug & RTL8XXXU_DEBUG_EFUSE) {
 		unsigned char *raw = priv->efuse_wifi.raw;
-- 
2.14.1
