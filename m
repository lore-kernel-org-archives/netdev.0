From: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Subject: [PATCH v2 00/12] net: ethernet: aquantia: Add AQtion 2.5/5 GB NIC driver
Date: Fri,  6 Jan 2017 00:06:01 -0800
Message-ID: <cover.1483689029.git.vomlehn@texas.net>
Cc: Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexander Loktionov <Alexander.Loktionov@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>
To: netdev@vger.kernel.org, David VomLehn <vomlehn@texas.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda4.aus1.datafoundry.com ([209.99.124.135]:60190 "EHLO
        milter.aus.datafoundry.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751936AbdAFIGk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 03:06:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David VomLehn <vomlehn@texas.net>

This series introduced the AQtion NIC driver for the aQuantia
AQC107/AQC108 network devices.

v1: Initial version
v2: o Make necessary drivers/net/ethernet changes to integrate software
    o Drop intermediate atlantic directory
    o Remove Makefile things only appropriate to out of tree module builidng

David VomLehn (12):
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

 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/aquantia/Kconfig              |   24 +
 drivers/net/ethernet/aquantia/Makefile             |   43 +
 drivers/net/ethernet/aquantia/aq_cfg.h             |   81 +
 drivers/net/ethernet/aquantia/aq_common.h          |   22 +
 drivers/net/ethernet/aquantia/aq_ethtool.c         |  250 +++
 drivers/net/ethernet/aquantia/aq_ethtool.h         |   19 +
 drivers/net/ethernet/aquantia/aq_hw.h              |  169 ++
 drivers/net/ethernet/aquantia/aq_hw_utils.c        |   68 +
 drivers/net/ethernet/aquantia/aq_hw_utils.h        |   47 +
 drivers/net/ethernet/aquantia/aq_main.c            |  298 +++
 drivers/net/ethernet/aquantia/aq_main.h            |   17 +
 drivers/net/ethernet/aquantia/aq_nic.c             |  964 ++++++++
 drivers/net/ethernet/aquantia/aq_nic.h             |  108 +
 drivers/net/ethernet/aquantia/aq_nic_internal.h    |   46 +
 drivers/net/ethernet/aquantia/aq_pci_func.c        |  354 +++
 drivers/net/ethernet/aquantia/aq_pci_func.h        |   34 +
 drivers/net/ethernet/aquantia/aq_ring.c            |  380 ++++
 drivers/net/ethernet/aquantia/aq_ring.h            |  147 ++
 drivers/net/ethernet/aquantia/aq_rss.h             |   26 +
 drivers/net/ethernet/aquantia/aq_utils.h           |   53 +
 drivers/net/ethernet/aquantia/aq_vec.c             |  373 +++
 drivers/net/ethernet/aquantia/aq_vec.h             |   37 +
 drivers/net/ethernet/aquantia/hw_atl/hw_atl_a0.c   |  909 ++++++++
 drivers/net/ethernet/aquantia/hw_atl/hw_atl_a0.h   |   34 +
 .../ethernet/aquantia/hw_atl/hw_atl_a0_internal.h  |  153 ++
 drivers/net/ethernet/aquantia/hw_atl/hw_atl_b0.c   |  967 ++++++++
 drivers/net/ethernet/aquantia/hw_atl/hw_atl_b0.h   |   34 +
 .../ethernet/aquantia/hw_atl/hw_atl_b0_internal.h  |  206 ++
 drivers/net/ethernet/aquantia/hw_atl/hw_atl_llh.c  | 1395 ++++++++++++
 drivers/net/ethernet/aquantia/hw_atl/hw_atl_llh.h  |  677 ++++++
 .../ethernet/aquantia/hw_atl/hw_atl_llh_internal.h | 2375 ++++++++++++++++++++
 .../net/ethernet/aquantia/hw_atl/hw_atl_utils.c    |  544 +++++
 .../net/ethernet/aquantia/hw_atl/hw_atl_utils.h    |  210 ++
 drivers/net/ethernet/aquantia/ver.h                |   18 +
 36 files changed, 11084 insertions(+)
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

Signed-off-by: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Signed-off-by: Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>
Signed-off-by: Pavel Belous <Pavel.Belous@aquantia.com>
Signed-off-by: David M. VomLehn <vomlehn@texas.net>

-- 
2.7.4
