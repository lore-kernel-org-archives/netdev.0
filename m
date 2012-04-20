From: Paolo Pisati <paolo.pisati@canonical.com>
Subject: [PATCH] smsc95xx: mark link down on startup and let PHY interrupt deal with carrier changes
Date: Fri, 20 Apr 2012 11:35:21 +0200
Message-ID: <1334914521-5990-1-git-send-email-paolo.pisati@canonical.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:59044 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751951Ab2DTJf3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 05:35:29 -0400
Received: from 2-230-238-136.ip204.fastwebnet.it ([2.230.238.136] helo=canonical.com)
	by youngberry.canonical.com with esmtpsa (TLS1.0:DHE_RSA_AES_128_CBC_SHA1:16)
	(Exim 4.71)
	(envelope-from <paolo.pisati@canonical.com>)
	id 1SLAFU-0003HE-5W
	for netdev@vger.kernel.org; Fri, 20 Apr 2012 09:35:28 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Without this patch sysfs reports the cable as present

flag@flag-desktop:~$ cat /sys/class/net/eth0/carrier
1

while it's not:

flag@flag-desktop:~$ sudo mii-tool eth0
eth0: no link

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
