From: Madalin Bucur <madalin.bucur@freescale.com>
Subject: [RFC,v3 00/10] Introduce DPAA Ethernet driver
Date: Wed, 29 Apr 2015 17:56:07 +0300
Message-ID: <1430319367-31234-1-git-send-email-madalin.bucur@freescale.com>
Reply-To: <madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <joe@perches.com>,
	<pebolle@tiscali.nl>, Madalin Bucur <madalin.bucur@freescale.com>
To: <netdev@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is the 3rd version of a patch series that adds
the Ethernet driver for the Freescale QorIQ Data Path
Acceleration Architecture (DPAA).

This version addresses the feedback received from Joe
Perches and Paul Bolle. 

Together with the driver a managed version of alloc_percpu
is provided that simplifies the release of percpu memory.

The Freescale DPAA architecture consists in a series of
hardware blocks that support the Ethernet connectivity.
the Ethernet driver depends upon the Peripheral Access
Memory Unit (PAMU), Frame Manager (FMan), Queue Manager
(QMan), Buffer Manager (BMan). Drivers for these blocks
are currently in the kernel or in review.

The current set of RFC patches is meant to provide early
access to the codebase and also provide context and aid
the review of the latest FMan driver patches submitted
by Igal Liberman:

https://patchwork.ozlabs.org/project/linuxppc-dev/list/?submitter=Igal.Liberman&state=*&q=RFC%2Cv3

These patches rely also on the Q/BMan drivers submitted
by Emil Medve:

https://patchwork.ozlabs.org/project/linuxppc-dev/list/?submitter=Emil+Medve&state=*&q=RFC

The complete set of patches will be available soon in this
public git repository under the ldup_public_git_20150429 tag:
http://git.freescale.com/git/cgit.cgi/ppc/upstream/linux.git/

Due to device tree binding changes, a u-boot patch is also
required to be applied to enable this set of drivers.
The u-boot patch is available in this public git under the 
ldup_public_git_20150410 tag:

http://git.freescale.com/git/cgit.cgi/ppc/upstream/u-boot.git/

The actual patch is 052f94430230e7ff388e6ae7daec45ba4f2f6b2f
powerpc/mpc85xx: align to the new FMan compatibles

http://git.freescale.com/git/cgit.cgi/ppc/upstream/u-boot.git/commit/?id=052f94430230e7ff388e6ae7daec45ba4f2f6b2f

The SDK documentation and source code, documentation for
the DPAA hardware are available at the company website.

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
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c     |  875 +++++++++++++
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.h     |  495 +++++++
 .../net/ethernet/freescale/dpaa/dpaa_eth_common.c  | 1379 ++++++++++++++++++++
 .../net/ethernet/freescale/dpaa/dpaa_eth_common.h  |  130 ++
 drivers/net/ethernet/freescale/dpaa/dpaa_eth_sg.c  |  726 +++++++++++
 .../net/ethernet/freescale/dpaa/dpaa_eth_sysfs.c   |  168 +++
 .../net/ethernet/freescale/dpaa/dpaa_eth_trace.h   |  141 ++
 drivers/net/ethernet/freescale/dpaa/dpaa_ethtool.c |  247 ++++
 include/linux/device.h                             |   19 +
 17 files changed, 4665 insertions(+)
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
