From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V15 0/4] ptp: IEEE 1588 hardware clock support
Date: Fri, 22 Apr 2011 12:02:23 +0200
Message-ID: <cover.1303466102.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-api@vger.kernel.org, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Arnd Bergmann <arnd@arndb.de>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Christoph Lameter <cl@linux.com>,
	David Miller <davem@davemloft.net>,
	John Stultz <john.stultz@linaro.org>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Mike Frysinger <vapier@gentoo.org>,
	Paul Mackerras <paulus@samba.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Rodolfo Giometti <giometti@linux.it>,
	Russell King <linux@arm.linux.org.uk>,
	Thomas Gleixner <tglx@linutronix.de>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here is V15 of the PHC patch series. I had been a bit lazy in adding
the acks that have accumulated since V13, and so now I have added them
into the commit message, unless the particular patch changed
substantially since the ack.

* Introduction

  The aim of this patch set is to add support for PTP Hardware Clocks
  (PHCs) into the Linux kernel. The patch series builds upon the
  dynamic posix clock work appearing in kernel version 2.6.39.

  Support for obtaining timestamps from a PHC already exists via the
  SO_TIMESTAMPING socket option, integrated in kernel version 2.6.30.
  This patch set completes the picture by allow user space programs to
  adjust the PHC and to control its ancillary features.

* Patches for ptpd on sf.net
  https://sourceforge.net/tracker/?group_id=139814&atid=744634
  3225599 [PATCH 1/3] Convert to POSIX clock API.
  3225603 [PATCH 2/3] Adapted to use the Linux PTP Hardware Clock API. 
  3225607 [PATCH 3/3] Adapted to use the newer SO_TIMESTAMPING Linux API.

* PHC Patch ChangeLog
** v15
*** general
    - allow test program to set system time from PTP HW clock
*** ixp46x and phyter packet matching
    - check packet bounds
    - handle variable ipv4 header length
    - replace magic numbers with macros

* Why all the CCs?
  - One driver is for PowerPC, and adds device tree stuff.
  - One driver is for the ARM Xscale IXP465.

* Previous Discussions
  - [V14] http://lkml.org/lkml/2011/4/18/16
  - [V13] http://lkml.org/lkml/2011/3/27/2
  - [V12] http://lkml.org/lkml/2011/2/28/53
  - [V11] http://lkml.org/lkml/2011/2/23/107
  - [V10] http://lkml.org/lkml/2011/1/27/71
  - [V9]  http://lkml.org/lkml/2011/1/13/65
  - [V8]  http://lkml.org/lkml/2010/12/31/128
  - [V7]  http://lkml.org/lkml/2010/12/16/195
  - [V6]  http://lkml.org/lkml/2010/9/23/310
  - [V5]  http://lkml.org/lkml/2010/8/16/90
  - Thomas Gleixner: Rework of the PTP support series core code
    http://lkml.org/lkml/2011/2/1/137
  - Dynamic clock devices [RFC]
    http://lkml.org/lkml/2010/11/4/290
  - POSIX clock tuning syscall with dynamic clock ids
    http://lkml.org/lkml/2010/9/3/119
  - POSIX clock tuning syscall with static clock ids
    http://lkml.org/lkml/2010/8/23/49
  - Versions 1-4 appeared on the netdev list.


Richard Cochran (4):
  ptp: Added a brand new class driver for ptp clocks.
  ptp: Added a clock that uses the eTSEC found on the MPC85xx.
  ptp: Added a clock driver for the IXP46x.
  ptp: Added a clock driver for the National Semiconductor PHYTER.

 Documentation/ABI/testing/sysfs-ptp                |   98 ++
 .../devicetree/bindings/net/fsl-tsec-phy.txt       |   54 +
 Documentation/ptp/ptp.txt                          |   89 ++
 Documentation/ptp/testptp.c                        |  381 +++++++
 Documentation/ptp/testptp.mk                       |   33 +
 arch/arm/mach-ixp4xx/include/mach/ixp46x_ts.h      |   78 ++
 arch/powerpc/boot/dts/mpc8313erdb.dts              |   13 +
 arch/powerpc/boot/dts/mpc8572ds.dts                |   13 +
 arch/powerpc/boot/dts/p2020ds.dts                  |   13 +
 arch/powerpc/boot/dts/p2020rdb.dts                 |   13 +
 drivers/Kconfig                                    |    2 +
 drivers/Makefile                                   |    1 +
 drivers/net/Makefile                               |    1 +
 drivers/net/arm/ixp4xx_eth.c                       |  195 ++++-
 drivers/net/gianfar_ptp.c                          |  588 +++++++++++
 drivers/net/phy/Makefile                           |    1 +
 drivers/net/phy/dp83640.c                          | 1100 ++++++++++++++++++++
 drivers/net/phy/dp83640_reg.h                      |  267 +++++
 drivers/ptp/Kconfig                                |   75 ++
 drivers/ptp/Makefile                               |    7 +
 drivers/ptp/ptp_chardev.c                          |  159 +++
 drivers/ptp/ptp_clock.c                            |  343 ++++++
 drivers/ptp/ptp_ixp46x.c                           |  332 ++++++
 drivers/ptp/ptp_private.h                          |   92 ++
 drivers/ptp/ptp_sysfs.c                            |  230 ++++
 include/linux/Kbuild                               |    1 +
 include/linux/ptp_classify.h                       |    7 +
 include/linux/ptp_clock.h                          |   84 ++
 include/linux/ptp_clock_kernel.h                   |  139 +++
 29 files changed, 4406 insertions(+), 3 deletions(-)
 create mode 100644 Documentation/ABI/testing/sysfs-ptp
 create mode 100644 Documentation/ptp/ptp.txt
 create mode 100644 Documentation/ptp/testptp.c
 create mode 100644 Documentation/ptp/testptp.mk
 create mode 100644 arch/arm/mach-ixp4xx/include/mach/ixp46x_ts.h
 create mode 100644 drivers/net/gianfar_ptp.c
 create mode 100644 drivers/net/phy/dp83640.c
 create mode 100644 drivers/net/phy/dp83640_reg.h
 create mode 100644 drivers/ptp/Kconfig
 create mode 100644 drivers/ptp/Makefile
 create mode 100644 drivers/ptp/ptp_chardev.c
 create mode 100644 drivers/ptp/ptp_clock.c
 create mode 100644 drivers/ptp/ptp_ixp46x.c
 create mode 100644 drivers/ptp/ptp_private.h
 create mode 100644 drivers/ptp/ptp_sysfs.c
 create mode 100644 include/linux/ptp_clock.h
 create mode 100644 include/linux/ptp_clock_kernel.h
