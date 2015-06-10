From: Madalin Bucur <madalin.bucur@freescale.com>
Subject: [PATCH 00/12] Freescale DPAA FMan
Date: Wed, 10 Jun 2015 18:21:40 +0300
Message-ID: <1433949712-5648-1-git-send-email-madalin.bucur@freescale.com>
Reply-To: <madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <scottwood@freescale.com>,
	Madalin Bucur <madalin.bucur@freescale.com>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linuxppc-dev@lists.ozlabs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0123.outbound.protection.outlook.com ([207.46.100.123]:7444
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753573AbbFJPXL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jun 2015 11:23:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Freescale Data Path Acceleration Architecture (DPAA)
is a set of hardware components on specific QorIQ multicore
processors. This architecture provides the infrastructure to
support simplified sharing of networking interfaces and
accelerators by multiple CPU cores and the accelerators.

One of the DPAA accelerators is the Frame Manager (FMan)
which contains a series of hardware blocks: ports, Ethernet
MACs, a multi user RAM (MURAM) and Storage Profile (SP).

This patch set introduced the FMan driver code that configures
and initializes the FMan hardware blocks, offering support for
three different types of MACs (DTSEC, TGEC, MEMAC).

The first 6 patches present the FMan Foundation Libraries (FLIBs).
The FMan drivers make use of the basic API the FMan FLib provides
to configure and control the FMan hardware. The remaining patches
present the required FMan hardware module drivers.

The driver structure and a hint on file naming:
 --------------------------------
|      FMan MAC driver           |	mac* files
 ------ ------ ----- ------- ----
| FMan | Port | MAC | MURAM | SP |	fm_* files
 ------ ------ ----- ------- ----
:      : FLib :     :             	fman_* files
 -------------------

This submission is based on the prior Freescale DPAA FMan V3,RFC
submission. Several issues addresses in this submission:
	- Reduced MAC layering and complexity
	- Reduced code base
	- T1024/T2080 10G best effort support

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
 .../net/ethernet/freescale/fman/flib/fsl_fman.h    |  609 ++++++
 .../ethernet/freescale/fman/flib/fsl_fman_dtsec.h  |  791 ++++++++
 .../freescale/fman/flib/fsl_fman_dtsec_mii_acc.h   |  103 +
 .../ethernet/freescale/fman/flib/fsl_fman_memac.h  |  453 +++++
 .../freescale/fman/flib/fsl_fman_memac_mii_acc.h   |   76 +
 .../ethernet/freescale/fman/flib/fsl_fman_port.h   |  427 ++++
 .../net/ethernet/freescale/fman/flib/fsl_fman_sp.h |   54 +
 .../ethernet/freescale/fman/flib/fsl_fman_tgec.h   |  409 ++++
 drivers/net/ethernet/freescale/fman/fm.c           | 2036 ++++++++++++++++++++
 drivers/net/ethernet/freescale/fman/fm.h           |  407 ++++
 drivers/net/ethernet/freescale/fman/fm_common.h    |  576 ++++++
 drivers/net/ethernet/freescale/fman/fm_drv.c       |  933 +++++++++
 drivers/net/ethernet/freescale/fman/fm_drv.h       |  125 ++
 drivers/net/ethernet/freescale/fman/fm_muram.c     |  127 ++
 drivers/net/ethernet/freescale/fman/fm_port_drv.c  |  496 +++++
 drivers/net/ethernet/freescale/fman/fm_sp_common.h |  104 +
 drivers/net/ethernet/freescale/fman/fman.c         |  973 ++++++++++
 .../ethernet/freescale/fman/inc/crc_mac_addr_ext.h |  343 ++++
 drivers/net/ethernet/freescale/fman/inc/enet_ext.h |  199 ++
 drivers/net/ethernet/freescale/fman/inc/fm_ext.h   |  453 +++++
 .../net/ethernet/freescale/fman/inc/fm_muram_ext.h |  103 +
 .../net/ethernet/freescale/fman/inc/fm_port_ext.h  |  376 ++++
 .../net/ethernet/freescale/fman/inc/fsl_fman_drv.h |  195 ++
 drivers/net/ethernet/freescale/fman/inc/mac.h      |  136 ++
 drivers/net/ethernet/freescale/fman/inc/net_ext.h  |  534 +++++
 drivers/net/ethernet/freescale/fman/inc/service.h  |   90 +
 drivers/net/ethernet/freescale/fman/mac/Makefile   |    8 +
 drivers/net/ethernet/freescale/fman/mac/fm_dtsec.c | 1089 +++++++++++
 drivers/net/ethernet/freescale/fman/mac/fm_dtsec.h |  227 +++
 .../ethernet/freescale/fman/mac/fm_dtsec_mii_acc.c |   82 +
 .../ethernet/freescale/fman/mac/fm_dtsec_mii_acc.h |   43 +
 drivers/net/ethernet/freescale/fman/mac/fm_mac.h   |  250 +++
 drivers/net/ethernet/freescale/fman/mac/fm_memac.c |  741 +++++++
 drivers/net/ethernet/freescale/fman/mac/fm_memac.h |  124 ++
 .../ethernet/freescale/fman/mac/fm_memac_mii_acc.c |   66 +
 .../ethernet/freescale/fman/mac/fm_memac_mii_acc.h |   50 +
 drivers/net/ethernet/freescale/fman/mac/fm_tgec.c  |  652 +++++++
 drivers/net/ethernet/freescale/fman/mac/fm_tgec.h  |  126 ++
 .../net/ethernet/freescale/fman/mac/fman_dtsec.c   |  571 ++++++
 .../freescale/fman/mac/fman_dtsec_mii_acc.c        |  168 ++
 .../net/ethernet/freescale/fman/mac/fman_memac.c   |  365 ++++
 .../freescale/fman/mac/fman_memac_mii_acc.c        |  217 +++
 .../net/ethernet/freescale/fman/mac/fman_tgec.c    |  217 +++
 drivers/net/ethernet/freescale/fman/mac/mac-api.c  |  765 ++++++++
 drivers/net/ethernet/freescale/fman/mac/mac.c      |  526 +++++
 drivers/net/ethernet/freescale/fman/port/Makefile  |    3 +
 drivers/net/ethernet/freescale/fman/port/fm_port.c | 1435 ++++++++++++++
 drivers/net/ethernet/freescale/fman/port/fm_port.h |  527 +++++
 .../net/ethernet/freescale/fman/port/fman_port.c   |  619 ++++++
 drivers/net/ethernet/freescale/fman/sp/Makefile    |    3 +
 drivers/net/ethernet/freescale/fman/sp/fm_sp.c     |  398 ++++
 58 files changed, 20850 insertions(+)
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
 create mode 100644 drivers/net/ethernet/freescale/fman/inc/enet_ext.h
 create mode 100644 drivers/net/ethernet/freescale/fman/inc/fm_ext.h
 create mode 100644 drivers/net/ethernet/freescale/fman/inc/fm_muram_ext.h
 create mode 100644 drivers/net/ethernet/freescale/fman/inc/fm_port_ext.h
 create mode 100644 drivers/net/ethernet/freescale/fman/inc/fsl_fman_drv.h
 create mode 100644 drivers/net/ethernet/freescale/fman/inc/mac.h
 create mode 100644 drivers/net/ethernet/freescale/fman/inc/net_ext.h
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
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fm_memac_mii_acc.h
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
1.7.11.7

I'm re-sending this as Igal's emails to netdev are not getting through.

Madalin
