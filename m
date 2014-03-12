From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net-next V4 0/9] Altera Triple Speed Ethernet (TSE) Driver
Date: Wed, 12 Mar 2014 15:15:25 -0500
Message-ID: <1394655334-29547-1-git-send-email-vbridgers2013@gmail.com>
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	rob@landley.net, vbridgers2013@gmail.com
To: devicetree@vger.kernel.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:55555 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752632AbaCLUUV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 16:20:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the version 4 submission for the Altera Triple Speed Ethernet (TSE)
driver. All comments received during the version 2 and 3 submissions have 
been accepted. Please find the change log and a description of the driver 
files submission below. 

Please consider this patch set for inclusion into the Linux kernel. 

Vince

V4: Address comments from V3 review
    - Change statistics names in ethtool module to follow common use in 
      other ethernet drivers.
    - remove an unnecessary case in ethtool module
    - change logging to use netdev_* where possible instead of dev_*
    - remove logging for OOM errors since those are already logged

V3: Address comments from V2 review
    - Reorder patch submission so that net/ethernet Makefile and Kconfig
      are committed last, thus not breaking bisect
    - Use of_get_mac_address instead of of_get_property
    - Change supplemental and hash configuration bindings to boolean/empty,
      and more meaningful names
    - Add check for failure from calls to of_phy_connect and 
      connect_local_phy
    - Correct code to find mdio child node
    - Update bindings document 
    - Remove cast to u64 when not necessary
    - add use of const for statistics strings

V2: Address comments from initial RFC review.
    - The driver files were broken up by major sections of functionality.
      These include MSGDMA, SGDMA, Misc, and Main. 
    - Add patch for MAINTAINERS file, add the maintainer for this submission
    - Use 32-bit lower/upper physical address accessor functions so the driver
      is 64-bit ready.
    - Use standard bindings where applicable. Especially phy-addr, and change
      "altr,rx-fifo-depth" to "rx-fifo-depth" and "altr,tx-fifo-depth" to 
      "tx-fifo-depth".
    - Add use of max-frame-size property
    - Update bindings documents accordingly
    - Correct interrupt handler to use budget parameter in the convential way
    - Use macros consistently to define bit fields across files
    - Correct include exclusion macro in altera_msgdmahw.h (typo)
    - Remove use of barriers, these were not necessary since the DMA APIs
      ensure memory & buffer consistency
    - Remove use of netif_carrier_off in driver
    - move probing of phy from the open function to the probe function
    - use of_get_phy_mode instead of custom function
    - Use the .data field in the device structure to obtain a pointer
      to SGDMA or MSGDMA device specific properties and functions. 
    - remove custom function to access devicetree since Altera specific
      bindings requiring it's use have been deprecated in favor of 
      standard bindings. 

The Altera TSE is a 10/100/1000 Mbps Ethernet soft IP component that can be
configured and synthesized using Quartus, and programmed into Altera FPGAs.
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

Vince Bridgers (9):
  dts: Add bindings for the Altera Triple Speed Ethernet driver
  Documentation: networking: Add Altera Ethernet (TSE) Documentation
  Altera TSE: Add Altera Ethernet Driver MSGDMA File Components
  Altera TSE: Add Altera Ethernet Driver SGDMA file components
  Altera TSE: Add Miscellaneous Files for Altera Ethernet Driver
  Altera TSE: Add main and header file for Altera Ethernet Driver
  Altera TSE: Add Altera Ethernet Driver Makefile and Kconfig
  MAINTAINERS: Add entry for Altera Triple Speed Ethernet Driver
  net: ethernet: Change Ethernet Makefile and Kconfig for Altera TSE
    driver

 .../devicetree/bindings/net/altera_tse.txt         |  114 ++
 Documentation/networking/altera_tse.txt            |  119 ++
 MAINTAINERS                                        |    7 +
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/altera/Kconfig                |    8 +
 drivers/net/ethernet/altera/Makefile               |    7 +
 drivers/net/ethernet/altera/altera_msgdma.c        |  203 +++
 drivers/net/ethernet/altera/altera_msgdma.h        |   34 +
 drivers/net/ethernet/altera/altera_msgdmahw.h      |  167 +++
 drivers/net/ethernet/altera/altera_sgdma.c         |  511 +++++++
 drivers/net/ethernet/altera/altera_sgdma.h         |   35 +
 drivers/net/ethernet/altera/altera_sgdmahw.h       |  124 ++
 drivers/net/ethernet/altera/altera_tse.h           |  486 +++++++
 drivers/net/ethernet/altera/altera_tse_ethtool.c   |  226 +++
 drivers/net/ethernet/altera/altera_tse_main.c      | 1535 ++++++++++++++++++++
 drivers/net/ethernet/altera/altera_utils.c         |   44 +
 drivers/net/ethernet/altera/altera_utils.h         |   27 +
 18 files changed, 3649 insertions(+)
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
 create mode 100644 drivers/net/ethernet/altera/altera_tse.h
 create mode 100644 drivers/net/ethernet/altera/altera_tse_ethtool.c
 create mode 100644 drivers/net/ethernet/altera/altera_tse_main.c
 create mode 100644 drivers/net/ethernet/altera/altera_utils.c
 create mode 100644 drivers/net/ethernet/altera/altera_utils.h

-- 
1.7.9.5
