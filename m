From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH net-next 0/3] Network driver for Armada 375 SoC
Date: Fri,  4 Jul 2014 15:31:34 -0300
Message-ID: <1404498697-21978-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: David Miller <davem@davemloft.net>,
	Jason Cooper <jason@lakedaemon.net>,
	Marcin Wojtas <mw@semihalf.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:60075 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756758AbaGDSec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jul 2014 14:34:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds a new network driver to support the network controller
in Armada 375 SoC.

The network interfaces share a common hardware unit called Packet Processor,
which contains a common register space and per-port register spaces.
    
The new network unit has different RXQ and TXQ management. The ports
associate so-called per-port "logical queues" which are mapped to "physical
queues". The latter are shared among the ports.

Fo the egress part, the mapping for each port is predefined by hardware.
The egress path incorporates so-called aggregation queues (one per CPU),
from where the data is passed to the physical queues and then via prefetch
buffer to the TxDMA.
    
The ingress path has a Parser and Classifier (PnC) and a Buffer Manager (BM)
whose usage is obligatory. We are only implementing a simple configuration
for the Parser and Classifier, yet the code is considerably large.
    
This network unit has other optional features like xPON, WoL, Hardware
Forwarding, and more. This initial commit doesn't provide support for these.
    
The mvpp2 network driver has been written by Marcin Wojtas and then reviewed
and cleaned up by Ezequiel Garcia.

Ezequiel Garcia (3):
  ethernet: Add new driver for Marvell Armada 375 network unit
  ARM: mvebu: Add support for the network controller in Armada 375 SoC
  ARM: mvebu: Enable the network controller in Armada 375 DB board

 .../devicetree/bindings/net/marvell-pp2.txt        |   61 +
 arch/arm/boot/dts/armada-375-db.dts                |   26 +
 arch/arm/boot/dts/armada-375.dtsi                  |   31 +
 drivers/net/ethernet/marvell/Kconfig               |    8 +
 drivers/net/ethernet/marvell/Makefile              |    1 +
 drivers/net/ethernet/marvell/mvpp2.c               | 6378 ++++++++++++++++++++
 6 files changed, 6505 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/marvell-pp2.txt
 create mode 100644 drivers/net/ethernet/marvell/mvpp2.c

-- 
1.9.1
