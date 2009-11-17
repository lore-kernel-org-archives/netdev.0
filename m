From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the net-current tree
Date: Tue, 17 Nov 2009 13:16:37 +1100
Message-ID: <20091117131637.3a35f898.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Wolfram Sang <w.sang@pengutronix.de>,
	Christian Pellegrin <chripell@fsfe.org>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Anant Gole <anantgole@ti.com>,
	Oliver Hartkopp <oliver@hartkopp.net>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:59153 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755187AbZKQCQg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Nov 2009 21:16:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

Today's linux-next merge of the net tree got a conflict in
drivers/net/can/Kconfig between commit
b93cf3f0bb45560d2ce62bdcc2181c40660cfdbf ("can: Fix driver Kconfig
structure") from the net-current tree and commits
3758bf25db8caeec667e4e56e030da0ec3060529 ("can: add TI CAN (HECC)
driver"), e0000163e30eeb112b41486ea113fd54f64e1f17 ("can: Driver for the
Microchip MCP251x SPI CAN controllers") and
afa17a500a3667f66df450100538d06769529bba ("net/can: add driver for mscan
family & mpc52xx_mscan") from the net tree.

I fixed it up (see below) and can carry the fix for a while. (I am not
sure the fix is entirely correct.)

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/can/Kconfig
index 772f6d2,c16e6ff..0000000
--- a/drivers/net/can/Kconfig
+++ b/drivers/net/can/Kconfig
@@@ -41,10 -95,38 +41,42 @@@ config CAN_AT9
  	---help---
  	  This is a driver for the SoC CAN controller in Atmel's AT91SAM9263.
  
+ config CAN_TI_HECC
+ 	depends on CAN_DEV && ARCH_OMAP3
+ 	tristate "TI High End CAN Controller"
+ 	---help---
+ 	  Driver for TI HECC (High End CAN Controller) module found on many
+ 	  TI devices. The device specifications are available from www.ti.com
+ 
+ config CAN_MCP251X
+ 	tristate "Microchip MCP251x SPI CAN controllers"
+ 	depends on CAN_DEV && SPI
+ 	---help---
+ 	  Driver for the Microchip MCP251x SPI CAN controllers.
+ 
+ config CAN_MSCAN
+ 	depends on CAN_DEV && (PPC || M68K || M68KNOMMU)
+ 	tristate "Support for Freescale MSCAN based chips"
+ 	---help---
+ 	  The Motorola Scalable Controller Area Network (MSCAN) definition
+ 	  is based on the MSCAN12 definition which is the specific
+ 	  implementation of the Motorola Scalable CAN concept targeted for
+ 	  the Motorola MC68HC12 Microcontroller Family.
+ 
+ config CAN_MPC52XX
+ 	tristate "Freescale MPC5xxx onboard CAN controller"
+ 	depends on CAN_MSCAN && PPC_MPC52xx
+ 	---help---
+ 	  If you say yes here you get support for Freescale's MPC52xx
+ 	  onboard dualCAN controller.
+ 
+ 	  This driver can also be built as a module.  If so, the module
+ 	  will be called mpc5xxx_can.
+ 
 +source "drivers/net/can/sja1000/Kconfig"
 +
 +source "drivers/net/can/usb/Kconfig"
 +
  config CAN_DEBUG_DEVICES
  	bool "CAN devices debugging messages"
  	depends on CAN
