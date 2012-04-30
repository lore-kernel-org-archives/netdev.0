From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 1/7] smsc75xx: mark link down on startup and let PHY interrupt deal with carrier changes
Date: Mon, 30 Apr 2012 18:56:50 +0100
Message-ID: <1335808616-22513-2-git-send-email-steve.glendinning@shawell.net>
References: <1335808616-22513-1-git-send-email-steve.glendinning@shawell.net>
Cc: David Miller <davem@davemloft.net>,
	Stephane Fillod <fillods@users.sf.net>,
	Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:49413 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756253Ab2D3R5L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 13:57:11 -0400
In-Reply-To: <1335808616-22513-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the same issue as reported on smsc95xx, where the
usb device is connected with no ethernet cable plugged-in.

Without this patch sysfs reports the cable as present

flag@flag-desktop:~$ cat /sys/class/net/eth0/carrier
1

while it's not:

flag@flag-desktop:~$ sudo mii-tool eth0
eth0: no link

Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
---
 drivers/net/usb/smsc75xx.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index a234948..b1b4649 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -1212,7 +1212,7 @@ static const struct driver_info smsc75xx_info = {
 	.rx_fixup	= smsc75xx_rx_fixup,
 	.tx_fixup	= smsc75xx_tx_fixup,
 	.status		= smsc75xx_status,
-	.flags		= FLAG_ETHER | FLAG_SEND_ZLP,
+	.flags		= FLAG_ETHER | FLAG_SEND_ZLP | FLAG_LINK_INTR,
 };
 
 static const struct usb_device_id products[] = {
-- 
1.7.9.5
