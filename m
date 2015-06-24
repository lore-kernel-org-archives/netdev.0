From: igal.liberman@freescale.com
Subject: [v2,0/9] Freescale DPAA FMan
Date: Wed, 24 Jun 2015 22:32:09 +0300
Message-ID: <1435174329-6896-1-git-send-email-igal.liberman@freescale.com>
Reply-To: igal.liberman@freescale.com
Mime-Version: 1.0
Content-Type: text/plain
Cc: linuxppc-dev@lists.ozlabs.org, scottwood@freescale.com,
	madalin.bucur@freescale.com, pebolle@tiscali.nl,
	Igal Liberman <igal.liberman@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0113.outbound.protection.outlook.com ([157.56.111.113]:10052
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752418AbbFXTcw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jun 2015 15:32:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Igal Liberman <igal.liberman@freescale.com>

The Freescale Data Path Acceleration Architecture (DPAA) is a set of 
hardware components on specific QorIQ multicore processors. This 
architecture provides the infrastructure to support simplified sharing 
of networking interfaces and accelerators by multiple CPU cores and 
the accelerators.

One of the DPAA accelerators is the Frame Manager (FMan) which 
contains a series of hardware blocks: ports, Ethernet MACs, a multi 
user RAM (MURAM) and Storage Profile (SP).

This patch set introduced the FMan driver code that configures and 
initializes the FMan hardware blocks, offering support for three 
different types of MACs (dTSEC, TGEC, MEMAC).

The first 3 patches present the FMan Foundation Libraries (FLIBs).
The FMan drivers make use of the basic API the FMan FLib provides to 
configure and control the FMan hardware. The remaining patches present 
the required FMan hardware module drivers.

The driver structure and a hint on file naming:
----------------------------------
|   FMan driver/MAC driver       |	fm_drv*, mac* files
----------------------------------
| FMan | Port | MAC | MURAM | SP |	fm_* files
----------------------------------
|			  FLib				 |	fman_* files
----------------------------------

v1 --> v2:
	- Addressed feedback from Paul Bolle:
		- General feedback of FMan Driver layer
		- Remove Errata defines
		- Aligned comments to Kernel Doc
		- Remove Loadable Module support (not yet supported)
		- Removed not needed KConfig dependencies 
	- Addressed feedback from Scott Wood
		- Use Kernel ioread/iowrite services
		- Squash FLIB source and header patches together


This submission is based on the prior Freescale DPAA FMan V3,RFC 
submission. Several issues addresses in this submission:
	- Reduced MAC layering and complexity
	- Reduced code base
	- T1024/T2080 10G best effort support

Igal Liberman (8):
  fsl/fman: Add the FMan FLIB
  fsl/fman: Add the FMan port FLIB
  fsl/fman: Add the FMan MAC FLIB
  fsl/fman: Add FMan MURAM support
  fsl/fman: Add Frame Manager support
  fsl/fman: Add FMan MAC support
  fsl/fman: Add FMan SP support
  fsl/fman: Add FMan MAC driver

Madalin Bucur (1):
  fsl/fman: Add FMan Port Support

 drivers/net/ethernet/freescale/Kconfig             |    1 +
 drivers/net/ethernet/freescale/Makefile            |    2 +
 drivers/net/ethernet/freescale/fman/Kconfig        |   44 +
 drivers/net/ethernet/freescale/fman/Makefile       |   12 +
 .../net/ethernet/freescale/fman/flib/fsl_enet.h    |  135 ++
 .../net/ethernet/freescale/fman/flib/fsl_fman.h    |  608 ++++++
 .../ethernet/freescale/fman/flib/fsl_fman_dtsec.h  |  830 +++++++++
 .../freescale/fman/flib/fsl_fman_dtsec_mii_acc.h   |   93 +
 .../ethernet/freescale/fman/flib/fsl_fman_memac.h  |  443 +++++
 .../freescale/fman/flib/fsl_fman_memac_mii_acc.h   |   75 +
 .../ethernet/freescale/fman/flib/fsl_fman_port.h   |  443 +++++
 .../net/ethernet/freescale/fman/flib/fsl_fman_sp.h |   53 +
 .../ethernet/freescale/fman/flib/fsl_fman_tgec.h   |  402 ++++
 drivers/net/ethernet/freescale/fman/fm.c           | 1941 ++++++++++++++++++++
 drivers/net/ethernet/freescale/fman/fm.h           |  397 ++++
 drivers/net/ethernet/freescale/fman/fm_common.h    |  265 +++
 drivers/net/ethernet/freescale/fman/fm_drv.c       |  784 ++++++++
 drivers/net/ethernet/freescale/fman/fm_drv.h       |  118 ++
 drivers/net/ethernet/freescale/fman/fm_muram.c     |  127 ++
 drivers/net/ethernet/freescale/fman/fm_port_drv.c  |  457 +++++
 drivers/net/ethernet/freescale/fman/fm_sp_common.h |  104 ++
 drivers/net/ethernet/freescale/fman/fman.c         |  975 ++++++++++
 .../ethernet/freescale/fman/inc/crc_mac_addr_ext.h |  314 ++++
 drivers/net/ethernet/freescale/fman/inc/enet_ext.h |  199 ++
 drivers/net/ethernet/freescale/fman/inc/fm_ext.h   |  488 +++++
 .../net/ethernet/freescale/fman/inc/fm_muram_ext.h |  112 ++
 .../net/ethernet/freescale/fman/inc/fm_port_ext.h  |  367 ++++
 .../net/ethernet/freescale/fman/inc/fsl_fman_drv.h |  212 +++
 drivers/net/ethernet/freescale/fman/inc/mac.h      |  136 ++
 drivers/net/ethernet/freescale/fman/inc/service.h  |   55 +
 drivers/net/ethernet/freescale/fman/mac/Makefile   |    8 +
 drivers/net/ethernet/freescale/fman/mac/fm_dtsec.c | 1053 +++++++++++
 drivers/net/ethernet/freescale/fman/mac/fm_dtsec.h |  209 +++
 .../ethernet/freescale/fman/mac/fm_dtsec_mii_acc.c |   80 +
 .../ethernet/freescale/fman/mac/fm_dtsec_mii_acc.h |   43 +
 drivers/net/ethernet/freescale/fman/mac/fm_mac.h   |  261 +++
 drivers/net/ethernet/freescale/fman/mac/fm_memac.c |  723 ++++++++
 drivers/net/ethernet/freescale/fman/mac/fm_memac.h |  123 ++
 .../ethernet/freescale/fman/mac/fm_memac_mii_acc.c |   63 +
 drivers/net/ethernet/freescale/fman/mac/fm_tgec.c  |  630 +++++++
 drivers/net/ethernet/freescale/fman/mac/fm_tgec.h  |  125 ++
 .../net/ethernet/freescale/fman/mac/fman_dtsec.c   |  530 ++++++
 .../freescale/fman/mac/fman_dtsec_mii_acc.c        |  168 ++
 .../net/ethernet/freescale/fman/mac/fman_memac.c   |  365 ++++
 .../freescale/fman/mac/fman_memac_mii_acc.c        |  217 +++
 .../net/ethernet/freescale/fman/mac/fman_tgec.c    |  215 +++
 drivers/net/ethernet/freescale/fman/mac/mac-api.c  |  765 ++++++++
 drivers/net/ethernet/freescale/fman/mac/mac.c      |  526 ++++++
 drivers/net/ethernet/freescale/fman/port/Makefile  |    3 +
 drivers/net/ethernet/freescale/fman/port/fm_port.c | 1345 ++++++++++++++
 drivers/net/ethernet/freescale/fman/port/fm_port.h |  521 ++++++
 .../net/ethernet/freescale/fman/port/fman_port.c   |  613 +++++++
 drivers/net/ethernet/freescale/fman/sp/Makefile    |    3 +
 drivers/net/ethernet/freescale/fman/sp/fm_sp.c     |  390 ++++
 54 files changed, 19171 insertions(+)
 create mode 100644 drivers/net/ethernet/freescale/fman/Kconfig
 create mode 100644 drivers/net/ethernet/freescale/fman/Makefile
 create mode 100644 drivers/net/ethernet/freescale/fman/flib/fsl_enet.h
 create mode 100644 drivers/net/ethernet/freescale/fman/flib/fsl_fman.h
 create mode 100644 drivers/net/ethernet/freescale/fman/flib/fsl_fman_dtsec.h
 create mode 100644 drivers/net/ethernet/freescale/fman/flib/fsl_fman_dtsec_mii_acc.h
 create mode 100644 drivers/net/ethernet/freescale/fman/flib/fsl_fman_memac.h
 create mode 100644 drivers/net/ethernet/freescale/fman/flib/fsl_fman_memac_mii_acc.h
 create mode 100644 drivers/net/ethernet/freescale/fman/flib/fsl_fman_port.h
 create mode 100644 drivers/net/ethernet/freescale/fman/flib/fsl_fman_sp.h
 create mode 100644 drivers/net/ethernet/freescale/fman/flib/fsl_fman_tgec.h
 create mode 100644 drivers/net/ethernet/freescale/fman/fm.c
 create mode 100644 drivers/net/ethernet/freescale/fman/fm.h
 create mode 100644 drivers/net/ethernet/freescale/fman/fm_common.h
 create mode 100644 drivers/net/ethernet/freescale/fman/fm_drv.c
 create mode 100644 drivers/net/ethernet/freescale/fman/fm_drv.h
 create mode 100644 drivers/net/ethernet/freescale/fman/fm_muram.c
 create mode 100644 drivers/net/ethernet/freescale/fman/fm_port_drv.c
 create mode 100644 drivers/net/ethernet/freescale/fman/fm_sp_common.h
 create mode 100644 drivers/net/ethernet/freescale/fman/fman.c
 create mode 100644 drivers/net/ethernet/freescale/fman/inc/crc_mac_addr_ext.h
 create mode 100644 drivers/net/ethernet/freescale/fman/inc/enet_ext.h
 create mode 100644 drivers/net/ethernet/freescale/fman/inc/fm_ext.h
 create mode 100644 drivers/net/ethernet/freescale/fman/inc/fm_muram_ext.h
 create mode 100644 drivers/net/ethernet/freescale/fman/inc/fm_port_ext.h
 create mode 100644 drivers/net/ethernet/freescale/fman/inc/fsl_fman_drv.h
 create mode 100644 drivers/net/ethernet/freescale/fman/inc/mac.h
 create mode 100644 drivers/net/ethernet/freescale/fman/inc/service.h
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/Makefile
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fm_dtsec.c
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fm_dtsec.h
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fm_dtsec_mii_acc.c
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fm_dtsec_mii_acc.h
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fm_mac.h
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fm_memac.c
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fm_memac.h
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fm_memac_mii_acc.c
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fm_tgec.c
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fm_tgec.h
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fman_dtsec.c
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fman_dtsec_mii_acc.c
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fman_memac.c
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fman_memac_mii_acc.c
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fman_tgec.c
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/mac-api.c
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/mac.c
 create mode 100644 drivers/net/ethernet/freescale/fman/port/Makefile
 create mode 100644 drivers/net/ethernet/freescale/fman/port/fm_port.c
 create mode 100644 drivers/net/ethernet/freescale/fman/port/fm_port.h
 create mode 100644 drivers/net/ethernet/freescale/fman/port/fman_port.c
 create mode 100644 drivers/net/ethernet/freescale/fman/sp/Makefile
 create mode 100644 drivers/net/ethernet/freescale/fman/sp/fm_sp.c

-- 
1.7.9.5
