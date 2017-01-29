From: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Subject: [PATCH stable v1 00/13] net: ethernet: aquantia: Add AQtion 2.5/5 GB NIC driver
Date: Sat, 28 Jan 2017 21:09:00 -0800
Message-ID: <cover.1485665881.git.vomlehn@texas.net>
Cc: "David S . Miller" <davem@davemloft.net>,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexander Loktionov <Alexander.Loktionov@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>
To: netdev@vger.kernel.org, David VomLehn <vomlehn@texas.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda1.aus1.datafoundry.com ([209.99.124.132]:38234 "EHLO
        milter.aus.datafoundry.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752148AbdA2Fxr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 00:53:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David VomLehn <vomlehn@texas.net>

This series introduces the AQtion NIC driver for the aQuantia
AQC107/AQC108 network devices.

The commit for the first patch of the upstream patchset on which this
is based is:

    665e17fb5a80e09a59f71e8264420c46810d0534.

The only difference with this patchset is how Aquantia directory is
patched into the make and Kconfig files.

Signed-off-by: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Signed-off-by: Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>
Signed-off-by: Pavel Belous <Pavel.Belous@aquantia.com>
Signed-off-by: David M. VomLehn <vomlehn@texas.net>
---
v1: Initial version. 

Applying this to version 4.9 is a priority for Aquantia as customers
running Ubuntu 16.10 in environments requiring stability are likely to
stay on this kernel version rather than upgrading to the tip. This
patchset also works with version 4.4. We would appreciate it if it could
be applied there, as well, for customers running older distros.

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
  net: ethernet: aquantia: Integrate AQtion 2.5/5 GB

 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/aquantia/Kconfig              |   24 +
 drivers/net/ethernet/aquantia/Makefile             |    5 +
 drivers/net/ethernet/aquantia/atlantic/Makefile    |   42 +
 drivers/net/ethernet/aquantia/atlantic/aq_cfg.h    |   77 +
 drivers/net/ethernet/aquantia/atlantic/aq_common.h |   23 +
 .../net/ethernet/aquantia/atlantic/aq_ethtool.c    |  261 +++
 .../net/ethernet/aquantia/atlantic/aq_ethtool.h    |   19 +
 drivers/net/ethernet/aquantia/atlantic/aq_hw.h     |  177 ++
 .../net/ethernet/aquantia/atlantic/aq_hw_utils.c   |   68 +
 .../net/ethernet/aquantia/atlantic/aq_hw_utils.h   |   47 +
 drivers/net/ethernet/aquantia/atlantic/aq_main.c   |  273 +++
 drivers/net/ethernet/aquantia/atlantic/aq_main.h   |   17 +
 drivers/net/ethernet/aquantia/atlantic/aq_nic.c    |  937 ++++++++
 drivers/net/ethernet/aquantia/atlantic/aq_nic.h    |  108 +
 .../ethernet/aquantia/atlantic/aq_nic_internal.h   |   46 +
 .../net/ethernet/aquantia/atlantic/aq_pci_func.c   |  345 +++
 .../net/ethernet/aquantia/atlantic/aq_pci_func.h   |   34 +
 drivers/net/ethernet/aquantia/atlantic/aq_ring.c   |  376 ++++
 drivers/net/ethernet/aquantia/atlantic/aq_ring.h   |  157 ++
 drivers/net/ethernet/aquantia/atlantic/aq_rss.h    |   26 +
 drivers/net/ethernet/aquantia/atlantic/aq_utils.h  |   50 +
 drivers/net/ethernet/aquantia/atlantic/aq_vec.c    |  392 ++++
 drivers/net/ethernet/aquantia/atlantic/aq_vec.h    |   42 +
 .../ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c  |  905 ++++++++
 .../ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.h  |   34 +
 .../aquantia/atlantic/hw_atl/hw_atl_a0_internal.h  |  155 ++
 .../ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c  |  958 ++++++++
 .../ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.h  |   34 +
 .../aquantia/atlantic/hw_atl/hw_atl_b0_internal.h  |  207 ++
 .../ethernet/aquantia/atlantic/hw_atl/hw_atl_llh.c | 1394 ++++++++++++
 .../ethernet/aquantia/atlantic/hw_atl/hw_atl_llh.h |  677 ++++++
 .../aquantia/atlantic/hw_atl/hw_atl_llh_internal.h | 2375 ++++++++++++++++++++
 .../aquantia/atlantic/hw_atl/hw_atl_utils.c        |  570 +++++
 .../aquantia/atlantic/hw_atl/hw_atl_utils.h        |  210 ++
 drivers/net/ethernet/aquantia/atlantic/ver.h       |   18 +
 37 files changed, 11085 insertions(+)
 create mode 100644 drivers/net/ethernet/aquantia/Kconfig
 create mode 100644 drivers/net/ethernet/aquantia/Makefile
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/Makefile
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/aq_cfg.h
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/aq_common.h
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/aq_ethtool.c
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/aq_ethtool.h
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/aq_hw.h
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/aq_hw_utils.c
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/aq_hw_utils.h
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/aq_main.c
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/aq_main.h
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/aq_nic.c
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/aq_nic.h
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/aq_nic_internal.h
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/aq_pci_func.c
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/aq_pci_func.h
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/aq_ring.c
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/aq_ring.h
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/aq_rss.h
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/aq_utils.h
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/aq_vec.c
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/aq_vec.h
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.h
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0_internal.h
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.h
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0_internal.h
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_llh.c
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_llh.h
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_llh_internal.h
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.c
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.h
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/ver.h

-- 
2.9.3
