From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 1/1] net: fix USB network driver config option.
Date: Thu, 7 Aug 2014 00:36:40 +0200
Message-ID: <20140806223640.GA24673@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-usb@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:46420 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752417AbaHFWhE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 18:37:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>

It must be tristate to avoid broken dependencies with kernel built-in
usb network drivers when usb support is module only.

When net config option is set, least surprize default should match usb.

Wireless RNDIS USB driver used to select USB_USBNET. USB_USBNET now
depends on USB_NET_DRIVERS so the latter should be selected as well.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/usb/Kconfig      | 4 ++--
 drivers/net/wireless/Kconfig | 1 +
 2 files changed, 3 insertions(+), 2 deletions(-)

It applies against plain linus 85417aef44fc58b08773117ceb1bc6ca5684e973.

diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index 9f194a0..37eed4d 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -5,8 +5,8 @@ comment "Host-side USB support is needed for USB Network Adapter support"
 	depends on !USB && NET
 
 menuconfig USB_NET_DRIVERS
-	bool "USB Network Adapters"
-	default y
+	tristate "USB Network Adapters"
+	default USB if USB
 	depends on USB && NET
 
 if USB_NET_DRIVERS
diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index b2137e8..16604bd 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -189,6 +189,7 @@ config USB_NET_RNDIS_WLAN
 	tristate "Wireless RNDIS USB support"
 	depends on USB
 	depends on CFG80211
+	select USB_NET_DRIVERS
 	select USB_USBNET
 	select USB_NET_CDCETHER
 	select USB_NET_RNDIS_HOST
-- 
1.9.3
