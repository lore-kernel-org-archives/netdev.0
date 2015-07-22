From: Madalin Bucur <madalin.bucur@freescale.com>
Subject: [PATCH 00/10] dpaa_eth: Add the Freescale DPAA Ethernet driver
Date: Wed, 22 Jul 2015 19:15:56 +0300
Message-ID: <1437581756-17371-1-git-send-email-madalin.bucur@freescale.com>
Reply-To: <madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linuxppc-dev@lists.ozlabs.org>, <linux-kernel@vger.kernel.org>,
	<scottwood@freescale.com>, <igal.liberman@freescale.com>,
	<ppc@mindchasers.com>, <joe@perches.com>, <pebolle@tiscali.nl>,
	<joakim.tjernlund@transmode.se>,
	Madalin Bucur <madalin.bucur@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series adds the Ethernet driver for the Freescale
QorIQ Data Path Acceleration Architecture (DPAA).

This version includes changes following the feedback received
on previous RFC versions from Eric Dumazet, Bob Cochran, Joe Perches,
Paul Bolle, Joakim Tjernlund, Scott Wood - thank you for your support.	

Together with the driver a managed version of alloc_percpu
is provided that simplifies the release of percpu memory.

The Freescale DPAA architecture consists in a series of hardware
blocks that support the Ethernet connectivity. The Ethernet driver
depends upon the following drivers that are currently in the Linux
kernel or in review:
 - Peripheral Access Memory Unit (PAMU)
    drivers/iommu/fsl_*
 - Frame Manager (FMan)
    drivers/net/ethernet/freescale/fman
 - Queue Manager (QMan), Buffer Manager (BMan)
    drivers/soc/fsl/qbman

The latest FMan driver patches were submitted by Igal Liberman:

https://patchwork.ozlabs.org/project/netdev/list/?submitter=64715&state=*&q=[v3,

The latest Q/BMan drivers were submitted by Roy Pledge:

https://patchwork.ozlabs.org/project/linuxppc-dev/list/?submitter=66331&state=*&q=11

Madalin Bucur (10):
  devres: add devm_alloc_percpu()
  dpaa_eth: add support for DPAA Ethernet
  dpaa_eth: add configurable bpool thresholds
  dpaa_eth: add support for S/G frames
  dpaa_eth: add driver's Tx queue selection mechanism
  dpaa_eth: add ethtool functionality
  dpaa_eth: add sysfs exports
  dpaa_eth: add debugfs counters
  dpaa_eth: add debugfs entries
  dpaa_eth: add trace points

 Documentation/driver-model/devres.txt              |    4 +
 drivers/base/devres.c                              |   64 +
 drivers/net/ethernet/freescale/Kconfig             |    2 +
 drivers/net/ethernet/freescale/Makefile            |    1 +
 drivers/net/ethernet/freescale/dpaa/Kconfig        |   81 ++
 drivers/net/ethernet/freescale/dpaa/Makefile       |   17 +
 drivers/net/ethernet/freescale/dpaa/dpaa_debugfs.c |  273 ++++
 drivers/net/ethernet/freescale/dpaa/dpaa_debugfs.h |   43 +
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c     |  873 +++++++++++++
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.h     |  496 +++++++
 .../net/ethernet/freescale/dpaa/dpaa_eth_common.c  | 1367 ++++++++++++++++++++
 .../net/ethernet/freescale/dpaa/dpaa_eth_common.h  |  130 ++
 drivers/net/ethernet/freescale/dpaa/dpaa_eth_sg.c  |  704 ++++++++++
 .../net/ethernet/freescale/dpaa/dpaa_eth_sysfs.c   |  167 +++
 .../net/ethernet/freescale/dpaa/dpaa_eth_trace.h   |  141 ++
 drivers/net/ethernet/freescale/dpaa/dpaa_ethtool.c |  230 ++++
 include/linux/device.h                             |   19 +
 17 files changed, 4612 insertions(+)
 create mode 100644 drivers/net/ethernet/freescale/dpaa/Kconfig
 create mode 100644 drivers/net/ethernet/freescale/dpaa/Makefile
 create mode 100644 drivers/net/ethernet/freescale/dpaa/dpaa_debugfs.c
 create mode 100644 drivers/net/ethernet/freescale/dpaa/dpaa_debugfs.h
 create mode 100644 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
 create mode 100644 drivers/net/ethernet/freescale/dpaa/dpaa_eth.h
 create mode 100644 drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.c
 create mode 100644 drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.h
 create mode 100644 drivers/net/ethernet/freescale/dpaa/dpaa_eth_sg.c
 create mode 100644 drivers/net/ethernet/freescale/dpaa/dpaa_eth_sysfs.c
 create mode 100644 drivers/net/ethernet/freescale/dpaa/dpaa_eth_trace.h
 create mode 100644 drivers/net/ethernet/freescale/dpaa/dpaa_ethtool.c

-- 
1.7.11.7
