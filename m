From: Roy Pledge <Roy.Pledge@freescale.com>
Subject: [v2 00/11] Freescale DPAA QBMan Drivers
Date: Wed, 12 Aug 2015 16:14:46 -0400
Message-ID: <1439410497-19039-1-git-send-email-Roy.Pledge@freescale.com>
Reply-To: <Roy.Pledge@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <linuxppc-dev@lists.ozlabs.org>, <scottwood@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The Freescale Data Path Acceleration Architecture (DPAA) is a set of hardware components on specific QorIQ multicore processors. This architecture provides the infrastructure to support simplified sharing of networking interfaces and accelerators by multiple CPU cores and the accelerators.

The Queue Manager (QMan) is a hardware queue management block that allows software and accelerators on the datapath to enqueue and dequeue frames in order to communicate.

The Buffer Manager (BMan) is a hardware buffer pool management block that allows software and accelerators on the datapath to acquire and release buffers in order to build frames.

This patch set introduces the QBMan driver code that configures initializes the QBMan hardware and provides APIs for software to use the frame queues and buffer pools the blocks provide. These drivers provide the base fuctionality for software to communicate with the other DPAA accelerators on Freescale QorIQ processors.

Changes from v1:
	- Cleanup Kconfig options
	- Changed base QMan and BMan drivers to only be buit in.
	  Will add loadable support in future patch
	- Replace panic() call with WARN_ON()
	- Elimanated some unused APIs
	- Replaced PowerPC specific IO accessors with platform independent versions



Emil Medve (1):
  powerpc: re-add devm_ioremap_prot()

Geoff Thorpe (7):
  soc/fsl: Introduce DPAA BMan device management driver
  soc/fsl: Introduce the DPAA BMan portal driver
  soc/fsl: Introduce drivers for the DPAA QMan
  soc/bman: Add self-tester for BMan driver
  soc/qman: Add self-tester for QMan driver
  soc/bman: Add debugfs support for the BMan driver
  soc/qman: Add debugfs support for the QMan driver

Hai-Ying Wang (2):
  soc/bman: Add HOTPLUG_CPU support to the BMan driver
  soc/qman: Add HOTPLUG_CPU support to the QMan driver

Madalin Bucur (1):
  soc/qman: add qman_delete_cgr_safe()

 arch/powerpc/include/asm/io.h                 |    3 +
 arch/powerpc/lib/Makefile                     |    1 +
 arch/powerpc/lib/devres.c                     |   43 +
 arch/powerpc/platforms/85xx/corenet_generic.c |   16 +
 arch/powerpc/platforms/85xx/p1023_rdb.c       |   14 +
 drivers/soc/Kconfig                           |    1 +
 drivers/soc/Makefile                          |    1 +
 drivers/soc/fsl/Kconfig                       |    5 +
 drivers/soc/fsl/Makefile                      |    3 +
 drivers/soc/fsl/qbman/Kconfig                 |  120 +
 drivers/soc/fsl/qbman/Makefile                |   20 +
 drivers/soc/fsl/qbman/bman-debugfs.c          |  117 +
 drivers/soc/fsl/qbman/bman.c                  |  553 +++++
 drivers/soc/fsl/qbman/bman.h                  |  542 +++++
 drivers/soc/fsl/qbman/bman_api.c              | 1072 +++++++++
 drivers/soc/fsl/qbman/bman_portal.c           |  391 ++++
 drivers/soc/fsl/qbman/bman_priv.h             |  134 ++
 drivers/soc/fsl/qbman/bman_test.c             |   56 +
 drivers/soc/fsl/qbman/bman_test.h             |   34 +
 drivers/soc/fsl/qbman/bman_test_api.c         |  184 ++
 drivers/soc/fsl/qbman/bman_test_thresh.c      |  198 ++
 drivers/soc/fsl/qbman/bman_utils.c            |   72 +
 drivers/soc/fsl/qbman/dpaa_resource.c         |  359 +++
 drivers/soc/fsl/qbman/dpaa_sys.h              |  271 +++
 drivers/soc/fsl/qbman/qman-debugfs.c          | 1313 +++++++++++
 drivers/soc/fsl/qbman/qman.c                  | 1026 +++++++++
 drivers/soc/fsl/qbman/qman.h                  | 1128 ++++++++++
 drivers/soc/fsl/qbman/qman_api.c              | 2921 +++++++++++++++++++++++++
 drivers/soc/fsl/qbman/qman_driver.c           |   83 +
 drivers/soc/fsl/qbman/qman_portal.c           |  672 ++++++
 drivers/soc/fsl/qbman/qman_priv.h             |  287 +++
 drivers/soc/fsl/qbman/qman_test.c             |   57 +
 drivers/soc/fsl/qbman/qman_test.h             |   44 +
 drivers/soc/fsl/qbman/qman_test_api.c         |  216 ++
 drivers/soc/fsl/qbman/qman_test_stash.c       |  502 +++++
 drivers/soc/fsl/qbman/qman_utils.c            |  305 +++
 include/soc/fsl/bman.h                        |  518 +++++
 include/soc/fsl/qman.h                        | 1977 +++++++++++++++++
 38 files changed, 15259 insertions(+)
 create mode 100644 arch/powerpc/lib/devres.c
 create mode 100644 drivers/soc/fsl/Kconfig
 create mode 100644 drivers/soc/fsl/Makefile
 create mode 100644 drivers/soc/fsl/qbman/Kconfig
 create mode 100644 drivers/soc/fsl/qbman/Makefile
 create mode 100644 drivers/soc/fsl/qbman/bman-debugfs.c
 create mode 100644 drivers/soc/fsl/qbman/bman.c
 create mode 100644 drivers/soc/fsl/qbman/bman.h
 create mode 100644 drivers/soc/fsl/qbman/bman_api.c
 create mode 100644 drivers/soc/fsl/qbman/bman_portal.c
 create mode 100644 drivers/soc/fsl/qbman/bman_priv.h
 create mode 100644 drivers/soc/fsl/qbman/bman_test.c
 create mode 100644 drivers/soc/fsl/qbman/bman_test.h
 create mode 100644 drivers/soc/fsl/qbman/bman_test_api.c
 create mode 100644 drivers/soc/fsl/qbman/bman_test_thresh.c
 create mode 100644 drivers/soc/fsl/qbman/bman_utils.c
 create mode 100644 drivers/soc/fsl/qbman/dpaa_resource.c
 create mode 100644 drivers/soc/fsl/qbman/dpaa_sys.h
 create mode 100644 drivers/soc/fsl/qbman/qman-debugfs.c
 create mode 100644 drivers/soc/fsl/qbman/qman.c
 create mode 100644 drivers/soc/fsl/qbman/qman.h
 create mode 100644 drivers/soc/fsl/qbman/qman_api.c
 create mode 100644 drivers/soc/fsl/qbman/qman_driver.c
 create mode 100644 drivers/soc/fsl/qbman/qman_portal.c
 create mode 100644 drivers/soc/fsl/qbman/qman_priv.h
 create mode 100644 drivers/soc/fsl/qbman/qman_test.c
 create mode 100644 drivers/soc/fsl/qbman/qman_test.h
 create mode 100644 drivers/soc/fsl/qbman/qman_test_api.c
 create mode 100644 drivers/soc/fsl/qbman/qman_test_stash.c
 create mode 100644 drivers/soc/fsl/qbman/qman_utils.c
 create mode 100644 include/soc/fsl/bman.h
 create mode 100644 include/soc/fsl/qman.h

--
1.7.9.5
