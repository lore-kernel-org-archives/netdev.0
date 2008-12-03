From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH next]if_usb: Kill directly reference of netdev->priv
Date: Wed, 03 Dec 2008 20:57:50 +0800
Message-ID: <4936824E.3060806@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58686 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752603AbYLCM54 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2008 07:57:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simply replace netdev->priv with netdev_priv().

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 drivers/net/wireless/libertas/if_usb.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/libertas/if_usb.c b/drivers/net/wireless/libertas/if_usb.c
index fcd3fe6..2fc637a 100644
--- a/drivers/net/wireless/libertas/if_usb.c
+++ b/drivers/net/wireless/libertas/if_usb.c
@@ -59,7 +59,7 @@ static int if_usb_reset_device(struct if_usb_card *cardp);
 static ssize_t if_usb_firmware_set(struct device *dev,
 		struct device_attribute *attr, const char *buf, size_t count)
 {
-	struct lbs_private *priv = to_net_dev(dev)->priv;
+	struct lbs_private *priv = netdev_priv(to_net_dev(dev));
 	struct if_usb_card *cardp = priv->card;
 	char fwname[FIRMWARE_NAME_MAX];
 	int ret;
@@ -86,7 +86,7 @@ static DEVICE_ATTR(lbs_flash_fw, 0200, NULL, if_usb_firmware_set);
 static ssize_t if_usb_boot2_set(struct device *dev,
 		struct device_attribute *attr, const char *buf, size_t count)
 {
-	struct lbs_private *priv = to_net_dev(dev)->priv;
+	struct lbs_private *priv = netdev_priv(to_net_dev(dev));
 	struct if_usb_card *cardp = priv->card;
 	char fwname[FIRMWARE_NAME_MAX];
 	int ret;
-- 
1.5.3.4


