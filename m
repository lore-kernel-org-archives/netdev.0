From: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Subject: [PATCH v4 00/13] net: ethernet: aquantia: Add AQtion 2.5/5 GB NIC driver
Date: Wed, 11 Jan 2017 19:53:04 -0800
Message-ID: <cover.1484192452.git.vomlehn@texas.net>
Cc: "David S . Miller" <davem@davemloft.net>,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexander Loktionov <Alexander.Loktionov@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>
To: netdev@vger.kernel.org, David VomLehn <vomlehn@texas.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda5.aus1.datafoundry.com ([209.99.124.136]:43658 "EHLO
        barracuda.datafoundry.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752167AbdALDx5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 22:53:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David VomLehn <vomlehn@texas.net>

This series introduces the AQtion NIC driver for the aQuantia
AQC107/AQC108 network devices.

v1: Initial version
v2: o Make necessary drivers/net/ethernet changes to integrate software
    o Drop intermediate atlantic directory
    o Remove Makefile things only appropriate to out of tree module
      building
v3: o Move changes to drivers/net/ethernet/{Kconfig,Makefile} to the last
      patch to ensure clean bisection.
    o Removed inline attribute aq_hw_write_req() as it was defined in
      only one .c file.
    o #included pci.h in aq_common.h to get struct pci definition.
    o Modified code to unlock based execution flow rather than using a flag.
    o Made a number of functions that were only used in a single file static.
    o Cleaned up error and return code handling in various places.
    o Remove AQ_CFG_IP_ALIGN definition.
    o Other minor code clean up.
v4: o Using do_div for 64 bit division.
    o Modified NIC statistics code.
    o Using build_skb instead netdev_alloc_skb for single fragment packets.
    o Removed extra aq_nic.o from Makefile

Signed-off-by: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Signed-off-by: Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>
Signed-off-by: Pavel Belous <Pavel.Belous@aquantia.com>
Signed-off-by: David M. VomLehn <vomlehn@texas.net>
---

David VomLehn (13):
  net: ethernet: aquantia: Make and configuration files.
  net: ethernet: aquantia: Common functions and definitions
  net: ethernet: aquantia: Add ring support code
  net: ethernet: aquantia: Low-level hardware interfaces
  net: ethernet: aquantia: Support for NIC-specific code
  net: ethernet: aquantia: Atlantic A0 and B0 specific functions.
  net: ethernet: aquantia: Vector operations
  net: ethernet: aquantia: PCI operations
  net: ethernet: aquantia: Atlantic hardware abstraction layer
  net: ethernet: aquantia: Hardware interface and utility functions
  net: ethernet: aquantia: Ethtool support
  net: ethernet: aquantia: Receive side scaling
  net: ethernet: aquantia: Integrate AQtion 2.5/5 GB NIC driver

 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/aquantia/Kconfig              |   24 +
 drivers/net/ethernet/aquantia/Makefile             |   43 +
 drivers/net/ethernet/aquantia/aq_cfg.h             |   78 +
 drivers/net/ethernet/aquantia/aq_common.h          |   24 +
 drivers/net/ethernet/aquantia/aq_ethtool.c         |  251 +++
 drivers/net/ethernet/aquantia/aq_ethtool.h         |   20 +
 drivers/net/ethernet/aquantia/aq_hw.h              |  170 ++
 drivers/net/ethernet/aquantia/aq_hw_utils.c        |   69 +
 drivers/net/ethernet/aquantia/aq_hw_utils.h        |   48 +
 drivers/net/ethernet/aquantia/aq_main.c            |  292 +++
 drivers/net/ethernet/aquantia/aq_main.h            |   18 +
 drivers/net/ethernet/aquantia/aq_nic.c             |  911 ++++++++
 drivers/net/ethernet/aquantia/aq_nic.h             |  109 +
 drivers/net/ethernet/aquantia/aq_nic_internal.h    |   47 +
 drivers/net/ethernet/aquantia/aq_pci_func.c        |  348 +++
 drivers/net/ethernet/aquantia/aq_pci_func.h        |   35 +
 drivers/net/ethernet/aquantia/aq_ring.c            |  359 +++
 drivers/net/ethernet/aquantia/aq_ring.h            |  158 ++
 drivers/net/ethernet/aquantia/aq_rss.h             |   27 +
 drivers/net/ethernet/aquantia/aq_utils.h           |   54 +
 drivers/net/ethernet/aquantia/aq_vec.c             |  386 ++++
 drivers/net/ethernet/aquantia/aq_vec.h             |   43 +
 drivers/net/ethernet/aquantia/hw_atl/hw_atl_a0.c   |  908 ++++++++
 drivers/net/ethernet/aquantia/hw_atl/hw_atl_a0.h   |   35 +
 .../ethernet/aquantia/hw_atl/hw_atl_a0_internal.h  |  153 ++
 drivers/net/ethernet/aquantia/hw_atl/hw_atl_b0.c   |  961 ++++++++
 drivers/net/ethernet/aquantia/hw_atl/hw_atl_b0.h   |   35 +
 .../ethernet/aquantia/hw_atl/hw_atl_b0_internal.h  |  206 ++
 drivers/net/ethernet/aquantia/hw_atl/hw_atl_llh.c  | 1395 ++++++++++++
 drivers/net/ethernet/aquantia/hw_atl/hw_atl_llh.h  |  678 ++++++
 .../ethernet/aquantia/hw_atl/hw_atl_llh_internal.h | 2376 ++++++++++++++++++++
 .../net/ethernet/aquantia/hw_atl/hw_atl_utils.c    |  548 +++++
 .../net/ethernet/aquantia/hw_atl/hw_atl_utils.h    |  211 ++
 drivers/net/ethernet/aquantia/ver.h                |   19 +
 36 files changed, 11041 insertions(+)
 create mode 100644 drivers/net/ethernet/aquantia/Kconfig
 create mode 100644 drivers/net/ethernet/aquantia/Makefile
 create mode 100644 drivers/net/ethernet/aquantia/aq_cfg.h
 create mode 100644 drivers/net/ethernet/aquantia/aq_common.h
 create mode 100644 drivers/net/ethernet/aquantia/aq_ethtool.c
 create mode 100644 drivers/net/ethernet/aquantia/aq_ethtool.h
 create mode 100644 drivers/net/ethernet/aquantia/aq_hw.h
 create mode 100644 drivers/net/ethernet/aquantia/aq_hw_utils.c
 create mode 100644 drivers/net/ethernet/aquantia/aq_hw_utils.h
 create mode 100644 drivers/net/ethernet/aquantia/aq_main.c
 create mode 100644 drivers/net/ethernet/aquantia/aq_main.h
 create mode 100644 drivers/net/ethernet/aquantia/aq_nic.c
 create mode 100644 drivers/net/ethernet/aquantia/aq_nic.h
 create mode 100644 drivers/net/ethernet/aquantia/aq_nic_internal.h
 create mode 100644 drivers/net/ethernet/aquantia/aq_pci_func.c
 create mode 100644 drivers/net/ethernet/aquantia/aq_pci_func.h
 create mode 100644 drivers/net/ethernet/aquantia/aq_ring.c
 create mode 100644 drivers/net/ethernet/aquantia/aq_ring.h
 create mode 100644 drivers/net/ethernet/aquantia/aq_rss.h
 create mode 100644 drivers/net/ethernet/aquantia/aq_utils.h
 create mode 100644 drivers/net/ethernet/aquantia/aq_vec.c
 create mode 100644 drivers/net/ethernet/aquantia/aq_vec.h
 create mode 100644 drivers/net/ethernet/aquantia/hw_atl/hw_atl_a0.c
 create mode 100644 drivers/net/ethernet/aquantia/hw_atl/hw_atl_a0.h
 create mode 100644 drivers/net/ethernet/aquantia/hw_atl/hw_atl_a0_internal.h
 create mode 100644 drivers/net/ethernet/aquantia/hw_atl/hw_atl_b0.c
 create mode 100644 drivers/net/ethernet/aquantia/hw_atl/hw_atl_b0.h
 create mode 100644 drivers/net/ethernet/aquantia/hw_atl/hw_atl_b0_internal.h
 create mode 100644 drivers/net/ethernet/aquantia/hw_atl/hw_atl_llh.c
 create mode 100644 drivers/net/ethernet/aquantia/hw_atl/hw_atl_llh.h
 create mode 100644 drivers/net/ethernet/aquantia/hw_atl/hw_atl_llh_internal.h
 create mode 100644 drivers/net/ethernet/aquantia/hw_atl/hw_atl_utils.c
 create mode 100644 drivers/net/ethernet/aquantia/hw_atl/hw_atl_utils.h
 create mode 100644 drivers/net/ethernet/aquantia/ver.h

-- 
2.7.4
