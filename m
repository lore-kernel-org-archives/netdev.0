From: <igal.liberman@freescale.com>
Subject: [v5, 0/6] Freescale DPAA FMan
Date: Thu, 24 Sep 2015 12:10:32 +0300
Message-ID: <1443085838-7539-1-git-send-email-igal.liberman@freescale.com>
Reply-To: <igal.liberman@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linuxppc-dev@lists.ozlabs.org>, <linux-kernel@vger.kernel.org>,
	<scottwood@freescale.com>, <madalin.bucur@freescale.com>,
	<pebolle@tiscali.nl>, <joakim.tjernlund@transmode.se>,
	<ppc@mindchasers.com>, <stephen@networkplumber.org>,
	<davem@davemloft.net>, Igal Liberman <igal.liberman@freescale.com>
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
MACs (dTSEC, tGEC, mEMAC).

v4 --> v5: 
	- Addressed feedback from David Miller:
		- Removed driver layering
		- Reduced namespace pollution 
		- Greatly reduced code complexity and size

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

Igal Liberman (6):
  fsl/fman: Add FMan MURAM support
  fsl/fman: Add FMan support
  fsl/fman: Add FMan MAC support
  fsl/fman: Add FMan SP support
  fsl/fman: Add FMan Port Support
  fsl/fman: Add FMan MAC driver

 drivers/net/ethernet/freescale/Kconfig             |    1 +
 drivers/net/ethernet/freescale/Makefile            |    2 +
 drivers/net/ethernet/freescale/fman/Kconfig        |    8 +
 drivers/net/ethernet/freescale/fman/Makefile       |    7 +
 .../net/ethernet/freescale/fman/crc_mac_addr_ext.h |  314 +++
 drivers/net/ethernet/freescale/fman/fman.c         | 2737 ++++++++++++++++++++
 drivers/net/ethernet/freescale/fman/fman.h         |  488 ++++
 drivers/net/ethernet/freescale/fman/fman_dtsec.c   | 1782 +++++++++++++
 drivers/net/ethernet/freescale/fman/fman_dtsec.h   |   59 +
 drivers/net/ethernet/freescale/fman/fman_mac.h     |  276 ++
 drivers/net/ethernet/freescale/fman/fman_memac.c   | 1374 ++++++++++
 drivers/net/ethernet/freescale/fman/fman_memac.h   |   60 +
 drivers/net/ethernet/freescale/fman/fman_muram.c   |  120 +
 drivers/net/ethernet/freescale/fman/fman_muram.h   |   90 +
 drivers/net/ethernet/freescale/fman/fman_port.c    | 1763 +++++++++++++
 drivers/net/ethernet/freescale/fman/fman_port.h    |  240 ++
 drivers/net/ethernet/freescale/fman/fman_sp.c      |  167 ++
 drivers/net/ethernet/freescale/fman/fman_sp.h      |  103 +
 drivers/net/ethernet/freescale/fman/fman_tgec.c    |  849 ++++++
 drivers/net/ethernet/freescale/fman/fman_tgec.h    |   55 +
 drivers/net/ethernet/freescale/fman/mac.c          |  963 +++++++
 drivers/net/ethernet/freescale/fman/mac.h          |  117 +
 22 files changed, 11575 insertions(+)
 create mode 100644 drivers/net/ethernet/freescale/fman/Kconfig
 create mode 100644 drivers/net/ethernet/freescale/fman/Makefile
 create mode 100644 drivers/net/ethernet/freescale/fman/crc_mac_addr_ext.h
 create mode 100644 drivers/net/ethernet/freescale/fman/fman.c
 create mode 100644 drivers/net/ethernet/freescale/fman/fman.h
 create mode 100644 drivers/net/ethernet/freescale/fman/fman_dtsec.c
 create mode 100644 drivers/net/ethernet/freescale/fman/fman_dtsec.h
 create mode 100644 drivers/net/ethernet/freescale/fman/fman_mac.h
 create mode 100644 drivers/net/ethernet/freescale/fman/fman_memac.c
 create mode 100644 drivers/net/ethernet/freescale/fman/fman_memac.h
 create mode 100644 drivers/net/ethernet/freescale/fman/fman_muram.c
 create mode 100644 drivers/net/ethernet/freescale/fman/fman_muram.h
 create mode 100644 drivers/net/ethernet/freescale/fman/fman_port.c
 create mode 100644 drivers/net/ethernet/freescale/fman/fman_port.h
 create mode 100644 drivers/net/ethernet/freescale/fman/fman_sp.c
 create mode 100644 drivers/net/ethernet/freescale/fman/fman_sp.h
 create mode 100644 drivers/net/ethernet/freescale/fman/fman_tgec.c
 create mode 100644 drivers/net/ethernet/freescale/fman/fman_tgec.h
 create mode 100644 drivers/net/ethernet/freescale/fman/mac.c
 create mode 100644 drivers/net/ethernet/freescale/fman/mac.h

-- 
1.7.9.5
