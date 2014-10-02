From: Michel Stam <m.stam@fugro.nl>
Subject: [PATCH] Don't reset PHY on if_up for ASIX 88772
Date: Thu,  2 Oct 2014 10:22:02 +0200
Message-ID: <1412238122-1914-1-git-send-email-m.stam@fugro.nl>
Cc: freddy@asix.com.tw, grundler@chromium.org,
	Michel Stam <m.stam@fugro.nl>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.reverze.net ([82.161.88.7]:53734 "EHLO fsm.reverze.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751344AbaJBIaR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2014 04:30:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've noticed every time the interface is set to 'up,', the kernel
reports that the link speed is set to 100 Mbps/Full Duplex, even
when ethtool is used to set autonegotiation to 'off', half
duplex, 10 Mbps.
It can be tested by:
 ifconfig eth0 down
 ethtool -s eth0 autoneg off speed 10 duplex half
 ifconfig eth0 up

Then checking 'dmesg' for the link speed.

Signed-off-by: Michel Stam <m.stam@fugro.nl>
---
 drivers/net/usb/asix_devices.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_devices.c
index 5d19409..2c05f6c 100644
--- a/drivers/net/usb/asix_devices.c
+++ b/drivers/net/usb/asix_devices.c
@@ -890,7 +890,7 @@ static const struct driver_info ax88772_info = {
 	.unbind = ax88772_unbind,
 	.status = asix_status,
 	.link_reset = ax88772_link_reset,
-	.reset = ax88772_reset,
+	.reset = ax88772_link_reset,
 	.flags = FLAG_ETHER | FLAG_FRAMING_AX | FLAG_LINK_INTR | FLAG_MULTI_PACKET,
 	.rx_fixup = asix_rx_fixup_common,
 	.tx_fixup = asix_tx_fixup,
-- 
1.7.12.1
