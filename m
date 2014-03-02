From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH RFC 0/3] Altera Triple Speed Ethernet (TSE) Driver RFC
Date: Sun,  2 Mar 2014 14:41:59 -0600
Message-ID: <1393792922-2381-1-git-send-email-vbridgers2013@gmail.com>
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	rob@landley.net, vbridgers2013@gmail.com
To: devicetree@vger.kernel.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f53.google.com ([209.85.219.53]:43310 "EHLO
	mail-oa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751976AbaCBUqz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2014 15:46:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm submitting this patch set for comments as a first step towards upstreaming 
a driver for the Altera Triple Speed Ethernet (TSE) controller. 

The Altera TSE is a 10/100/1000 Mbps Ethernet soft IP component that can be 
configured and synthesize using Quartus, and programmed into Altera FPGAs. 
Two types of soft DMA IP components are supported by this driver - the Altera
SGDMA and the MSGDMA. The MSGDMA DMA component is preferred over the SGDMA,
since the SGDMA will be deprecated in favor of the MSGDMA. Software supporting
both is provided for customers still using the SGDMA and to demonstrate how
multiple types of DMA engines may be supported by the TSE driver in the event
customers wish to develop their own custom soft DMA engine for particular
applications. 

The design has been tested on Altera's Cyclone 4, 5, and Cyclone 5 SOC
development kits using an ARM A9 processor and an Altera NIOS2 processor.
Differences in CPU/DMA coherency management and address alignment are
addressed by proper use of driver APIs and semantics.

Patch 1/3 is for the device bindings used by the TSE driver, patch 2/3 is for
the driver documentation, and patch 3/3 is the driver code submission.  

I welcome comments on how best to achieve these objectives, and how best to
work with the community to upstream support for the Altera Triple Speed
Ethernet controller.  

Thank you in advance for constructive comments,

Best regards, 

Vince

Vince Bridgers (3):
  dts: Add bindings for the Altera Triple Speed Ethernet Driver
  Documentation: networking: Add Altera Triple Speed Ethernet (TSE)
    Documentation
  Altera TSE: Add Altera Triple Speed Ethernet (TSE) Driver

 .../devicetree/bindings/net/altera_tse.txt         |  114 ++
 Documentation/networking/altera_tse.txt            |  119 ++
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/altera/Kconfig                |    8 +
 drivers/net/ethernet/altera/Makefile               |    7 +
 drivers/net/ethernet/altera/altera_msgdma.c        |  205 +++
 drivers/net/ethernet/altera/altera_msgdma.h        |   35 +
 drivers/net/ethernet/altera/altera_msgdmahw.h      |  168 +++
 drivers/net/ethernet/altera/altera_sgdma.c         |  558 +++++++
 drivers/net/ethernet/altera/altera_sgdma.h         |   36 +
 drivers/net/ethernet/altera/altera_sgdmahw.h       |  125 ++
 drivers/net/ethernet/altera/altera_tse.c           | 1578 ++++++++++++++++++++
 drivers/net/ethernet/altera/altera_tse.h           |  477 ++++++
 drivers/net/ethernet/altera/altera_tse_ethtool.c   |  226 +++
 drivers/net/ethernet/altera/altera_utils.c         |   46 +
 drivers/net/ethernet/altera/altera_utils.h         |   28 +
 17 files changed, 3732 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/altera_tse.txt
 create mode 100644 Documentation/networking/altera_tse.txt
 create mode 100644 drivers/net/ethernet/altera/Kconfig
 create mode 100644 drivers/net/ethernet/altera/Makefile
 create mode 100644 drivers/net/ethernet/altera/altera_msgdma.c
 create mode 100644 drivers/net/ethernet/altera/altera_msgdma.h
 create mode 100644 drivers/net/ethernet/altera/altera_msgdmahw.h
 create mode 100644 drivers/net/ethernet/altera/altera_sgdma.c
 create mode 100644 drivers/net/ethernet/altera/altera_sgdma.h
 create mode 100644 drivers/net/ethernet/altera/altera_sgdmahw.h
 create mode 100644 drivers/net/ethernet/altera/altera_tse.c
 create mode 100644 drivers/net/ethernet/altera/altera_tse.h
 create mode 100644 drivers/net/ethernet/altera/altera_tse_ethtool.c
 create mode 100644 drivers/net/ethernet/altera/altera_utils.c
 create mode 100644 drivers/net/ethernet/altera/altera_utils.h

-- 
1.7.9.5
