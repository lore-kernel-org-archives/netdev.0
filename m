From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -next/mmotm] net/can: fix softing build errors
Date: Fri, 11 Feb 2011 22:33:12 -0800
Message-ID: <20110211223312.be571303.randy.dunlap@oracle.com>
References: <201102110100.p1B10sDx029244@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	Kurt Van Dijck <kurt.van.dijck@eia.be>
To: akpm@linux-foundation.org, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:33705 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750950Ab1BLGfZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Feb 2011 01:35:25 -0500
In-Reply-To: <201102110100.p1B10sDx029244@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix can/softing build errors due to kconfig error.

kconfig tells us about a problem...

warning: (CAN_SOFTING_CS) selects CAN_SOFTING which has unmet direct dependencies (NET && CAN && CAN_DEV && HAS_IOMEM)

and then this is what happens due to that kconfig problem:

ERROR: "register_candev" [drivers/net/can/softing/softing.ko] undefined!
ERROR: "alloc_candev" [drivers/net/can/softing/softing.ko] undefined!
ERROR: "can_bus_off" [drivers/net/can/softing/softing.ko] undefined!
ERROR: "close_candev" [drivers/net/can/softing/softing.ko] undefined!
ERROR: "free_candev" [drivers/net/can/softing/softing.ko] undefined!
ERROR: "unregister_candev" [drivers/net/can/softing/softing.ko] undefined!
ERROR: "alloc_can_skb" [drivers/net/can/softing/softing.ko] undefined!
ERROR: "open_candev" [drivers/net/can/softing/softing.ko] undefined!

with this partial config:

CONFIG_CAN=m
# CONFIG_CAN_RAW is not set
# CONFIG_CAN_BCM is not set
# CAN Device Drivers
# CONFIG_CAN_VCAN is not set
CONFIG_CAN_SLCAN=m
# CONFIG_CAN_DEV is not set
CONFIG_CAN_SOFTING=m
CONFIG_CAN_SOFTING_CS=m
# CONFIG_CAN_DEBUG_DEVICES is not set

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Kurt Van Dijck <kurt.van.dijck@eia.be>
---
 drivers/net/can/softing/Kconfig |    1 +
 1 file changed, 1 insertion(+)

--- mmotm-2011-0210-1626.orig/drivers/net/can/softing/Kconfig
+++ mmotm-2011-0210-1626/drivers/net/can/softing/Kconfig
@@ -18,6 +18,7 @@ config CAN_SOFTING
 config CAN_SOFTING_CS
 	tristate "Softing Gmbh CAN pcmcia cards"
 	depends on PCMCIA
+	depends on CAN_DEV && HAS_IOMEM
 	select CAN_SOFTING
 	---help---
 	  Support for PCMCIA cards from Softing Gmbh & some cards
