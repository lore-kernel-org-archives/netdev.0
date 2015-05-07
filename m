From: <0001-fsl-fman-Add-the-FMan-FLIB-headers.patch@tx30smr01.am.freescale.net>
Subject: [RFC,v3 00/12] Freescale DPAA FMan
Date: Thu, 7 May 2015 15:58:25 +0300
Message-ID: <1431003505-14796-1-git-send-email-madalin.bucur@freescale.com>
References: <0002-fsl-fman-Add-the-FMan-FLIB.patch             \>
Reply-To: <madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Madalin Bucur <madalin.bucur@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0064.outbound.protection.outlook.com ([65.55.169.64]:35776
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751086AbbEGM6d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 May 2015 08:58:33 -0400
In-Reply-To: <0002-fsl-fman-Add-the-FMan-FLIB.patch             \>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Madalin Bucur <madalin.bucur@freescale.com>

From: Igal Liberman <igal.liberman@freescale.com>

The Freescale Data Path Acceleration Architecture (DPAA)
is a set of hardware components on specific QorIQ multicore
processors. This architecture provides the infrastructure to
support simplified sharing of networking interfaces and
accelerators by multiple CPU cores and the accelerators.

One of the DPAA accelerators is the Frame Manager (FMan)
which contains a series of hardware blocks:
ports, Ethernet MACs, a multi user RAM (MURAM) and
Storage Profile (SP).

This patch set introduced the FMan driver code that configures
and initializes the FMan hardware blocks, offering support for
three different types of MACs.
The first 6 patches present the FMan Foundation Libraries (FLIBs),
the FMan FLib provides the basic API used by the FMan drivers
to configure and control the FMan hardware.
The following patches present the FMan driver itself,
split into patches for each required hardware module.

v3:	- Moved FMan to ./drivers/net/ethernet/freescale/
	- Use genalloc for MURAM management.
	- Some updates for T1024 support.

v2:	- This set of patches combines the following submissions:
		- v2 of FMan (RFC)
		- v3 of FMan FLib
	- Reduced FMan code size:
		- Reduced FMan FLib's size:
			Removed code for future support.
		- Removed Priority Flow Control (PFC) support.
		- Removed rate-limiter.
		- Removed some MAC features.
		- Removed Real Time Clock (RTC) support.

I'm resending this as Igal's emails are not reaching netdev.

Igal Liberman (12):
  fsl/fman: Add the FMan FLIB headers
  fsl/fman: Add the FMan FLIB
  fsl/fman: Add the FMan port FLIB headers
  fsl/fman: Add the FMan port FLIB
  fsl/fman: Add the FMan MAC FLIB headers
  fsl/fman: Add the FMan MAC FLIB
  fsl/fman: Add FMan MURAM support
  fsl/fman: Add Frame Manager support
  fsl/fman: Add FMan MAC support
  fsl/fman: Add FMan SP support
  fsl/fman: Add FMan Port Support
  fsl/fman: Add FMan MAC driver

 drivers/net/ethernet/freescale/Kconfig             |    1 +
 drivers/net/ethernet/freescale/Makefile            |    2 +
 drivers/net/ethernet/freescale/fman/Kconfig        |   46 +
 drivers/net/ethernet/freescale/fman/Makefile       |   12 +
 .../ethernet/freescale/fman/flib/common/general.h  |   41 +
 .../net/ethernet/freescale/fman/flib/fman_common.h |   73 +
 .../net/ethernet/freescale/fman/flib/fsl_enet.h    |  275 +++
 .../net/ethernet/freescale/fman/flib/fsl_fman.h    |  743 +++++++
 .../ethernet/freescale/fman/flib/fsl_fman_dtsec.h  |  791 ++++++++
 .../freescale/fman/flib/fsl_fman_dtsec_mii_acc.h   |  103 +
 .../ethernet/freescale/fman/flib/fsl_fman_memac.h  |  453 +++++
 .../freescale/fman/flib/fsl_fman_memac_mii_acc.h   |   76 +
 .../ethernet/freescale/fman/flib/fsl_fman_port.h   |  462 +++++
 .../net/ethernet/freescale/fman/flib/fsl_fman_sp.h |   66 +
 .../ethernet/freescale/fman/flib/fsl_fman_tgec.h   |  409 ++++
 drivers/net/ethernet/freescale/fman/fm.c           | 2082 ++++++++++++++++++++
 drivers/net/ethernet/freescale/fman/fm.h           |  488 +++++
 drivers/net/ethernet/freescale/fman/fm_common.h    |  538 +++++
 drivers/net/ethernet/freescale/fman/fm_drv.c       |  973 +++++++++
 drivers/net/ethernet/freescale/fman/fm_drv.h       |  123 ++
 drivers/net/ethernet/freescale/fman/fm_muram.c     |  114 ++
 drivers/net/ethernet/freescale/fman/fm_port_drv.c  |  536 +++++
 drivers/net/ethernet/freescale/fman/fm_sp_common.h |  104 +
 drivers/net/ethernet/freescale/fman/fman.c         |  978 +++++++++
 .../ethernet/freescale/fman/inc/crc_mac_addr_ext.h |  343 ++++
 drivers/net/ethernet/freescale/fman/inc/dpaa_ext.h |  253 +++
 .../freescale/fman/inc/dpaa_integration_ext.h      |  120 ++
 drivers/net/ethernet/freescale/fman/inc/enet_ext.h |  199 ++
 drivers/net/ethernet/freescale/fman/inc/fm_ext.h   |  715 +++++++
 .../net/ethernet/freescale/fman/inc/fm_mac_ext.h   |  452 +++++
 .../net/ethernet/freescale/fman/inc/fm_muram_ext.h |   89 +
 .../net/ethernet/freescale/fman/inc/fm_port_ext.h  |  397 ++++
 .../net/ethernet/freescale/fman/inc/fsl_fman_drv.h |  192 ++
 drivers/net/ethernet/freescale/fman/inc/mac.h      |  125 ++
 drivers/net/ethernet/freescale/fman/inc/net_ext.h  |  534 +++++
 drivers/net/ethernet/freescale/fman/inc/service.h  |   90 +
 drivers/net/ethernet/freescale/fman/mac/Makefile   |    9 +
 drivers/net/ethernet/freescale/fman/mac/dtsec.c    | 1226 ++++++++++++
 drivers/net/ethernet/freescale/fman/mac/dtsec.h    |  185 ++
 .../ethernet/freescale/fman/mac/dtsec_mii_acc.c    |   82 +
 .../ethernet/freescale/fman/mac/dtsec_mii_acc.h    |   43 +
 drivers/net/ethernet/freescale/fman/mac/fm_mac.c   |  510 +++++
 drivers/net/ethernet/freescale/fman/mac/fm_mac.h   |  183 ++
 .../net/ethernet/freescale/fman/mac/fman_crc32.c   |  116 ++
 .../net/ethernet/freescale/fman/mac/fman_crc32.h   |   39 +
 .../net/ethernet/freescale/fman/mac/fman_dtsec.c   |  571 ++++++
 .../freescale/fman/mac/fman_dtsec_mii_acc.c        |  168 ++
 .../net/ethernet/freescale/fman/mac/fman_memac.c   |  365 ++++
 .../freescale/fman/mac/fman_memac_mii_acc.c        |  217 ++
 .../net/ethernet/freescale/fman/mac/fman_tgec.c    |  217 ++
 drivers/net/ethernet/freescale/fman/mac/mac-api.c  |  605 ++++++
 drivers/net/ethernet/freescale/fman/mac/mac.c      |  527 +++++
 drivers/net/ethernet/freescale/fman/mac/memac.c    |  837 ++++++++
 drivers/net/ethernet/freescale/fman/mac/memac.h    |  103 +
 .../ethernet/freescale/fman/mac/memac_mii_acc.c    |   66 +
 .../ethernet/freescale/fman/mac/memac_mii_acc.h    |   50 +
 drivers/net/ethernet/freescale/fman/mac/tgec.c     |  797 ++++++++
 drivers/net/ethernet/freescale/fman/mac/tgec.h     |  112 ++
 .../net/ethernet/freescale/fman/mac/tgec_mii_acc.h |   66 +
 drivers/net/ethernet/freescale/fman/port/Makefile  |    3 +
 drivers/net/ethernet/freescale/fman/port/fm_port.c | 1484 ++++++++++++++
 drivers/net/ethernet/freescale/fman/port/fm_port.h |  711 +++++++
 .../net/ethernet/freescale/fman/port/fman_port.c   |  728 +++++++
 drivers/net/ethernet/freescale/fman/sp/Makefile    |    3 +
 drivers/net/ethernet/freescale/fman/sp/fm_sp.c     |  398 ++++
 65 files changed, 23419 insertions(+)
 create mode 100644 drivers/net/ethernet/freescale/fman/Kconfig
 create mode 100644 drivers/net/ethernet/freescale/fman/Makefile
 create mode 100644 drivers/net/ethernet/freescale/fman/flib/common/general.h
 create mode 100644 drivers/net/ethernet/freescale/fman/flib/fman_common.h
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
 create mode 100644 drivers/net/ethernet/freescale/fman/inc/dpaa_ext.h
 create mode 100644 drivers/net/ethernet/freescale/fman/inc/dpaa_integration_ext.h
 create mode 100644 drivers/net/ethernet/freescale/fman/inc/enet_ext.h
 create mode 100644 drivers/net/ethernet/freescale/fman/inc/fm_ext.h
 create mode 100644 drivers/net/ethernet/freescale/fman/inc/fm_mac_ext.h
 create mode 100644 drivers/net/ethernet/freescale/fman/inc/fm_muram_ext.h
 create mode 100644 drivers/net/ethernet/freescale/fman/inc/fm_port_ext.h
 create mode 100644 drivers/net/ethernet/freescale/fman/inc/fsl_fman_drv.h
 create mode 100644 drivers/net/ethernet/freescale/fman/inc/mac.h
 create mode 100644 drivers/net/ethernet/freescale/fman/inc/net_ext.h
 create mode 100644 drivers/net/ethernet/freescale/fman/inc/service.h
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/Makefile
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/dtsec.c
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/dtsec.h
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/dtsec_mii_acc.c
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/dtsec_mii_acc.h
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fm_mac.c
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fm_mac.h
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fman_crc32.c
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fman_crc32.h
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fman_dtsec.c
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fman_dtsec_mii_acc.c
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fman_memac.c
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fman_memac_mii_acc.c
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fman_tgec.c
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/mac-api.c
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/mac.c
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/memac.c
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/memac.h
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/memac_mii_acc.c
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/memac_mii_acc.h
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/tgec.c
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/tgec.h
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/tgec_mii_acc.h
 create mode 100644 drivers/net/ethernet/freescale/fman/port/Makefile
 create mode 100644 drivers/net/ethernet/freescale/fman/port/fm_port.c
 create mode 100644 drivers/net/ethernet/freescale/fman/port/fm_port.h
 create mode 100644 drivers/net/ethernet/freescale/fman/port/fman_port.c
 create mode 100644 drivers/net/ethernet/freescale/fman/sp/Makefile
 create mode 100644 drivers/net/ethernet/freescale/fman/sp/fm_sp.c

-- 
1.7.11.7
