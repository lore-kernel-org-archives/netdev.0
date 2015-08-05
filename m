From: <igal.liberman@freescale.com>
Subject: [v4, 0/9] Freescale DPAA FMan
Date: Wed, 5 Aug 2015 12:25:16 +0300
Message-ID: <1438766725-8053-1-git-send-email-igal.liberman@freescale.com>
Reply-To: <igal.liberman@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linuxppc-dev@lists.ozlabs.org>, <linux-kernel@vger.kernel.org>,
	<scottwood@freescale.com>, <madalin.bucur@freescale.com>,
	<pebolle@tiscali.nl>, <joakim.tjernlund@transmode.se>,
	<ppc@mindchasers.com>, <stephen@networkplumber.org>,
	Igal Liberman <igal.liberman@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Igal Liberman <igal.liberman@freescale.com>

The Freescale Data Path Acceleration Architecture (DPAA)
is a set of hardware components on specific QorIQ multicore processors.
This architecture provides the infrastructure to support simplified
sharing of networking interfaces and accelerators by multiple CPU cores
and the accelerators.

One of the DPAA accelerators is the Frame Manager (FMan) which contains a
series of hardware blocks: ports, Ethernet MACs, a multi user RAM (MURAM)
and Storage Profile (SP).

This patch set introduce the FMan drivers. Each driver configures
and initializes the corresponding FMan hardware module (described above).
The MAC driver offers support for three different types of
MACs (eTSEC, TGEC, MEMAC).

The driver structure and a hint on file naming:
----------------------------------
|   FMan driver/MAC driver       |	fm_drv*, mac* files
----------------------------------
| FMan | Port | MAC | MURAM | SP |	fm_* files
----------------------------------
|		FLib		  |	fman_*.c, fsl_fman_.*h files
----------------------------------

The first 3 patches present the FMan Foundation Libraries (FLIBs).
The FLIBs provide basic internal API for the FMan hardware
configuration and control.
Header files are located in fman/flib directory.
Source files are located in each module directory.

The upper layer of the FMan driver makes use of the basic API which is
provided by the Flibs.

The remaining patches present the required FMan hardware module drivers.

v3 --> v4:
	- Remove device_initcall call in driver registration (redundant)
	- Remove hot/cold labels
	- Minor update in FMan Clock read from device-tree
	- Update fixed-link support
	- Addressed feedback from Stephen Hemminger
		- Remove bogus blank line

v2 --> v3:
	- Addressed feedback from Scott:
		- Remove typedefs
		- Remove unnecessary memory barriers
		- Remove unnecessary casting
		- Remove KConfig options
		- Remove early_params
		- Remove Hungarian notation
		- Remove __packed__  attribute and padding from structures
		- Remove unlikely attribute (where it's not needed)
		- Use proper error codes and remove unnecessary prints
		- Use proper values for sleep routines
		- Replace complex Macros with functions
		- Improve device tree processing code
		- Use symbolic defines
		- Add time-out in busy-wait loops
		- Removed exit code (loadable module support will be added later)
	- Fixed "fixed-link" issue raised by Joakim Tjernlund

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


This submission is based on the prior Freescale DPAA FMan V3,RFC submission.
Several issues addresses in this submission:
	- Reduced MAC layering and complexity
	- Reduced code base
	- T1024/T2080 10G best effort support


Igal Liberman (9):
  fsl/fman: Add the FMan FLIB
  fsl/fman: Add the FMan port FLIB
  fsl/fman: Add the FMan MAC FLIB
  fsl/fman: Add FMan MURAM support
  fsl/fman: Add Frame Manager support
  fsl/fman: Add FMan MAC support
  fsl/fman: Add FMan SP support
  fsl/fman: Add FMan Port Support
  fsl/fman: Add FMan MAC driver

 drivers/net/ethernet/freescale/Kconfig             |    1 +
 drivers/net/ethernet/freescale/Makefile            |    2 +
 drivers/net/ethernet/freescale/fman/Kconfig        |    8 +
 drivers/net/ethernet/freescale/fman/Makefile       |   12 +
 .../net/ethernet/freescale/fman/flib/fsl_enet.h    |  135 ++
 .../net/ethernet/freescale/fman/flib/fsl_fman.h    |  590 +++++++++
 .../ethernet/freescale/fman/flib/fsl_fman_dtsec.h  |  809 ++++++++++++
 .../freescale/fman/flib/fsl_fman_dtsec_mii_acc.h   |   89 ++
 .../ethernet/freescale/fman/flib/fsl_fman_memac.h  |  429 ++++++
 .../freescale/fman/flib/fsl_fman_memac_mii_acc.h   |   72 ++
 .../ethernet/freescale/fman/flib/fsl_fman_port.h   |  409 ++++++
 .../net/ethernet/freescale/fman/flib/fsl_fman_sp.h |   53 +
 .../ethernet/freescale/fman/flib/fsl_fman_tgec.h   |  393 ++++++
 drivers/net/ethernet/freescale/fman/fm.c           | 1366 ++++++++++++++++++++
 drivers/net/ethernet/freescale/fman/fm.h           |  279 ++++
 drivers/net/ethernet/freescale/fman/fm_common.h    |  178 +++
 drivers/net/ethernet/freescale/fman/fm_drv.c       |  621 +++++++++
 drivers/net/ethernet/freescale/fman/fm_drv.h       |  111 ++
 drivers/net/ethernet/freescale/fman/fm_muram.c     |  115 ++
 drivers/net/ethernet/freescale/fman/fm_port_drv.c  |  372 ++++++
 drivers/net/ethernet/freescale/fman/fm_sp_common.h |  105 ++
 drivers/net/ethernet/freescale/fman/fman.c         |  911 +++++++++++++
 .../ethernet/freescale/fman/inc/crc_mac_addr_ext.h |  314 +++++
 drivers/net/ethernet/freescale/fman/inc/enet_ext.h |  199 +++
 drivers/net/ethernet/freescale/fman/inc/fm_ext.h   |  446 +++++++
 .../net/ethernet/freescale/fman/inc/fm_muram_ext.h |  102 ++
 .../net/ethernet/freescale/fman/inc/fm_port_ext.h  |  340 +++++
 .../net/ethernet/freescale/fman/inc/fsl_fman_drv.h |  203 +++
 drivers/net/ethernet/freescale/fman/inc/mac.h      |  135 ++
 drivers/net/ethernet/freescale/fman/mac/Makefile   |    8 +
 drivers/net/ethernet/freescale/fman/mac/fm_dtsec.c | 1012 +++++++++++++++
 drivers/net/ethernet/freescale/fman/mac/fm_dtsec.h |  207 +++
 drivers/net/ethernet/freescale/fman/mac/fm_mac.h   |  259 ++++
 drivers/net/ethernet/freescale/fman/mac/fm_memac.c |  700 ++++++++++
 drivers/net/ethernet/freescale/fman/mac/fm_memac.h |  122 ++
 drivers/net/ethernet/freescale/fman/mac/fm_tgec.c  |  552 ++++++++
 drivers/net/ethernet/freescale/fman/mac/fm_tgec.h  |  124 ++
 .../net/ethernet/freescale/fman/mac/fman_dtsec.c   |  503 +++++++
 .../freescale/fman/mac/fman_dtsec_mii_acc.c        |  153 +++
 .../net/ethernet/freescale/fman/mac/fman_memac.c   |  374 ++++++
 .../freescale/fman/mac/fman_memac_mii_acc.c        |  151 +++
 .../net/ethernet/freescale/fman/mac/fman_tgec.c    |  207 +++
 drivers/net/ethernet/freescale/fman/mac/mac-api.c  |  688 ++++++++++
 drivers/net/ethernet/freescale/fman/mac/mac.c      |  445 +++++++
 drivers/net/ethernet/freescale/fman/port/Makefile  |    3 +
 drivers/net/ethernet/freescale/fman/port/fm_port.c | 1081 ++++++++++++++++
 drivers/net/ethernet/freescale/fman/port/fm_port.h |  502 +++++++
 .../net/ethernet/freescale/fman/port/fman_port.c   |  510 ++++++++
 drivers/net/ethernet/freescale/fman/sp/Makefile    |    3 +
 drivers/net/ethernet/freescale/fman/sp/fm_sp.c     |  371 ++++++
 50 files changed, 16774 insertions(+)
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
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/Makefile
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fm_dtsec.c
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fm_dtsec.h
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fm_mac.h
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fm_memac.c
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fm_memac.h
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
