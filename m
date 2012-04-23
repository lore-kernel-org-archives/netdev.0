From: Paolo Pisati <paolo.pisati@canonical.com>
Subject: [PATCH v2] smsc95xx: mark link down on startup and let PHY interrupt deal with carrier changes
Date: Mon, 23 Apr 2012 16:05:20 +0200
Message-ID: <1335189920-31062-1-git-send-email-paolo.pisati@canonical.com>
Cc: netdev@vger.kernel.org, Paolo Pisati <paolo.pisati@canonical.com>
To: Steve Glendinning <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:40866 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755391Ab2DWOGF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 10:06:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Without this patch sysfs reports the cable as present

flag@flag-desktop:~$ cat /sys/class/net/eth0/carrier
1

while it's not:

flag@flag-desktop:~$ sudo mii-tool eth0
eth0: no link

Tested on my Beagle XM.

v2: added mantainer to the list of recipient

Signed-off-by: Paolo Pisati <paolo.pisati@canonical.com>
---
 drivers/net/usb/smsc95xx.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 3444514..93d3252 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -1192,7 +1192,7 @@ static const struct driver_info smsc95xx_info = {
 	.rx_fixup	= smsc95xx_rx_fixup,
 	.tx_fixup	= smsc95xx_tx_fixup,
 	.status		= smsc95xx_status,
-	.flags		= FLAG_ETHER | FLAG_SEND_ZLP,
+	.flags		= FLAG_ETHER | FLAG_SEND_ZLP | FLAG_LINK_INTR,
 };
 
 static const struct usb_device_id products[] = {
-- 
1.7.9.5
