From: Anton Vorontsov <avorontsov@mvista.com>
Subject: [PATCH] gianfar: Revive the driver for eTSEC devices (disable
 timestamping)
Date: Wed, 9 Jun 2010 23:32:19 +0400
Message-ID: <20100609193219.GA8629@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Manfred Rudigier <Manfred.Rudigier@omicron.at>,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imap.ru.mvista.com ([213.79.90.228]:27427 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751551Ab0FITcU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 15:32:20 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit cc772ab7cdcaa24d1fae332d92a1602788644f7a ("gianfar: Add
hardware RX timestamping support"), the driver no longer works on
at least MPC8313ERDB and MPC8568EMDS boards (and possibly much more
boards as well).

That's how MPC8313 Reference Manual describes RCTRL_TS_ENABLE bit:

  Timestamp incoming packets as padding bytes. PAL field is set
  to 8 if the PAL field is programmed to less than 8. Must be set
  to zero if TMR_CTRL[TE]=0.

I see that the commit above sets this bit, but it doesn't handle
TMR_CTRL. Manfred probably had this bit set by the firmware for
his boards. But obviously this isn't true for all boards in the
wild.

Also, I recall that Freescale BSPs were explicitly disabling the
timestamping because of a performance drop.

For now, the best way to deal with this is just disable the
timestamping, and later we can discuss proper device tree bindings
and implement enabling this feature via some property.

Signed-off-by: Anton Vorontsov <avorontsov@mvista.com>
---
 drivers/net/gianfar.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 1830f31..46c69cd 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -747,8 +747,7 @@ static int gfar_of_init(struct of_device *ofdev, struct net_device **pdev)
 			FSL_GIANFAR_DEV_HAS_CSUM |
 			FSL_GIANFAR_DEV_HAS_VLAN |
 			FSL_GIANFAR_DEV_HAS_MAGIC_PACKET |
-			FSL_GIANFAR_DEV_HAS_EXTENDED_HASH |
-			FSL_GIANFAR_DEV_HAS_TIMER;
+			FSL_GIANFAR_DEV_HAS_EXTENDED_HASH;
 
 	ctype = of_get_property(np, "phy-connection-type", NULL);
 
-- 
1.7.0.5
