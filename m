From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH] can: c_can_pci: limit compilation to archs with clock support
Date: Wed, 20 Jun 2012 11:48:08 +0200
Message-ID: <1340185688-9454-1-git-send-email-mkl@pengutronix.de>
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Federico Vaga <federico.vaga@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:47909 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756001Ab2FTJsN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 05:48:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit:

  5b92da0 c_can_pci: generic module for C_CAN/D_CAN on PCI

the c_can_pci driver has been added. It uses clk_*() functions
unconditionally, resulting in a link error on archs without
clock support. This patch adds a "depends on HAVE_CLK" to the
Kconfig symbol.

An upcoming patch from Viresh Kumar adds a generic dummy
implementation. As soons as this patch has been merged, this
Kconfig symbol can be removed.

Cc: Federico Vaga <federico.vaga@gmail.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/c_can/Kconfig |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/can/c_can/Kconfig b/drivers/net/can/c_can/Kconfig
index 3b83baf..2835277 100644
--- a/drivers/net/can/c_can/Kconfig
+++ b/drivers/net/can/c_can/Kconfig
@@ -17,6 +17,7 @@ config CAN_C_CAN_PLATFORM
 config CAN_C_CAN_PCI
 	tristate "Generic PCI Bus based C_CAN/D_CAN driver"
 	depends on PCI
+	depends on HAVE_CLK
 	---help---
 	  This driver adds support for the C_CAN/D_CAN chips connected
 	  to the PCI bus.
-- 
1.7.10
