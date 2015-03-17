From: Madalin Bucur <madalin.bucur@freescale.com>
Subject: [PATCH RFC 00/11] introduce DPAA Ethernet driver
Date: Tue, 17 Mar 2015 20:57:00 +0200
Message-ID: <1426618620-15040-1-git-send-email-madalin.bucur@freescale.com>
Reply-To: <madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Madalin Bucur <madalin.bucur@freescale.com>
To: <netdev@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series introduces the Ethernet driver for the
Freescale QorIQ Data Path Acceleration Architecture (DPAA).
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
the review of the FMan driver patches submitted by Igal
Liberman:

[RFC,8/8] soc/fman: Add FMan MAC driver
[RFC,7/8] soc/fman: Add FMan Port Support
[RFC,6/8] soc/fman: Add FMan SP support
[RFC,5/8] soc/fman: Add FMan MAC support
[RFC,4/8] soc/fman: Add FMan Parser and Keygen support
[RFC,3/8] soc/fman: Add FMan Real Time Clock support
[RFC,2/8] soc/fman: Add Frame Manager support
[RFC,1/8] soc/fman: Add FMan MURAM support
[v2,11/11] soc/fman: Add the FMan SP FLIB
[v2,10/11] soc/fman: Add the FMan RTC FLIB
[v2,09/11] soc/fman: Add the FMan RTC FLIB header
[v2,08/11] soc/fman: Add the FMan parser and KeyGen FLIB(s)
[v2,07/11] soc/fman: Add the FMan parser and KeyGen FLIB headers
[v2,06/11] soc/fman: Add the FMan MAC FLIB
[v2,05/11] soc/fman: Add the FMan MAC FLIB headers
[v2,04/11] soc/fman: Add the FMan port FLIB
[v2,03/11] soc/fman: Add the FMan port FLIB headers
[v2,02/11] soc/fman: Add the FMan FLIB
[v2,01/11] soc/fman: Add the FMan FLIB headers

https://patchwork.ozlabs.org/project/linuxppc-dev/list/?submitter=Igal.Liberman&state=*

These patches rely also on the Q/BMan drivers submitted by
Emil Medve:

[RFC,v3,10/10] fsl_qman: Add HOTPLUG_CPU support
[RFC,v3,09/10] fsl_bman: Add HOTPLUG_CPU support
[RFC,v3,08/10] fsl_qman: Add debugfs support
[RFC,v3,07/10] fsl_bman: Add debugfs support
[RFC,v3,06/10] fsl_qman: Add self-tester
[RFC,v3,05/10] fsl_bman: Add self-tester
[RFC,v3,04/10] powerpc/mpc85xx: Add platform support for the Freescale DPAA QMan
[RFC,v3,03/10] powerpc/mpc85xx: Add platform support for the Freescale DPAA BMan
[RFC,v3,02/10] fsl_qman: Add drivers for the Freescale DPAA QMan
[RFC,v3,01/10] fsl_bman: Add drivers for the Freescale DPAA BMan

https://patchwork.ozlabs.org/project/linuxppc-dev/list/?submitter=Emil+Medve&state=*&q=RFC

The DPAA Ethernet driver is the result of the collaborative
work of many individuals, to name a few:
 Andy Fleming
 Emil Medve
 Kumar Gala
 Ioana Radulescu
 Bogdan Hamciuc
 Madalin Bucur
 Cristian Sovaiala
 Marian Rotariu
 Andrei Pistirica
 Cristian Bercaru
 
The current patch set is the result of a sustained clean-up
and adaptation work on the QorIQ DPAA drivers released in
the open source Freescale SDK. The SDK drivers differ as they
offer support for advanced accelerations and other features
that are not upstreamable. The SDK Ethernet driver is based
on a different, non-upstreamable variant of the FMan driver.
The short term goal is to provide basic Ethernet support in
the vanilla kernel then to gradually increase the feature set. 

The SDK documentation and source code, documentation for the
DPAA hardware are available from the company website.

Madalin Bucur (11):
  devres: add devm_alloc_percpu()
  dpaa_eth: add support for DPAA Ethernet
  dpaa_eth: add PM ops
  dpaa_eth: add configurable bpool thresholds
  dpaa_eth: add support for S/G frames
  dpaa_eth: add driver's Tx queue selection mechanism
  dpaa_eth: add ethtool functionality
  dpaa_eth: add sysfs exports
  dpaa_eth: add debugfs counters
  dpaa_eth: add debugfs entries
  dpaa_eth: add trace points

 Documentation/driver-model/devres.txt              |    4 +
 drivers/base/devres.c                              |   63 +
 drivers/net/ethernet/freescale/Kconfig             |    2 +
 drivers/net/ethernet/freescale/Makefile            |    1 +
 drivers/net/ethernet/freescale/dpaa/Kconfig        |   87 ++
 drivers/net/ethernet/freescale/dpaa/Makefile       |   18 +
 drivers/net/ethernet/freescale/dpaa/dpaa_debugfs.c |  273 ++++
 drivers/net/ethernet/freescale/dpaa/dpaa_debugfs.h |   43 +
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c     |  992 ++++++++++++++
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.h     |  503 +++++++
 .../net/ethernet/freescale/dpaa/dpaa_eth_common.c  | 1387 ++++++++++++++++++++
 .../net/ethernet/freescale/dpaa/dpaa_eth_common.h  |  130 ++
 drivers/net/ethernet/freescale/dpaa/dpaa_eth_sg.c  |  725 ++++++++++
 .../net/ethernet/freescale/dpaa/dpaa_eth_sysfs.c   |  168 +++
 .../net/ethernet/freescale/dpaa/dpaa_eth_trace.h   |  143 ++
 drivers/net/ethernet/freescale/dpaa/dpaa_ethtool.c |  301 +++++
 include/linux/device.h                             |   19 +
 17 files changed, 4859 insertions(+)
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
