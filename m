From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH v3 0/3] ptp: IEEE 1588 clock support
Date: Fri, 14 May 2010 18:44:53 +0200
Message-ID: <cover.1273855016.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@lists.ozlabs.org, devicetree-discuss@lists.ozlabs.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:33666 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751422Ab0ENQoo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 12:44:44 -0400
Received: by fxm6 with SMTP id 6so1699490fxm.19
        for <netdev@vger.kernel.org>; Fri, 14 May 2010 09:44:43 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now and again there has been talk on this list of adding PTP support
into Linux. One part of the picture is already in place, the
SO_TIMESTAMPING API for hardware time stamping. This patch set offers
the missing second part needed for complete IEEE 1588 support.

The only feature still to be implemented is the hook into the PPS
subsystem, to synchronize the Linux clock to the PTP clock.

Enjoy,
Richard

* Patch ChangeLog
** v3
*** general
   - Added documentation on writing clock drivers.
   - Added the ioctls for the ancillary clock features.
   - Changed wrong subsys_initcall() to module_init() in clock drivers.
   - Removed the (too coarse) character device mutex.
   - Setting the clock now requires CAP_SYS_TIME.
*** gianfar
   - Added alarm feature.
   - Added device tree node binding description.
   - Added fine grain locking of the clock registers.
   - Added the external time stamp feature.
   - Added white space for better style.
   - Coverted base+offset to structure pointers for register access.
   - When removing the driver, we now disable all PTP functions.

** v2
   - Changed clock list from a static array into a dynamic list. Also,
     use a bitmap to manage the clock's minor numbers.
   - Replaced character device semaphore with a mutex.
   - Drop .ko from module names in Kbuild help.
   - Replace deprecated unifdef-y with header-y for user space header file.
   - Added links to both of the ptpd patches on sourceforge.
   - Gianfar driver now gets parameters from device tree.
   - Added API documentation to Documentation/ptp/ptp.txt


Richard Cochran (3):
  ptp: Added a brand new class driver for ptp clocks.
  ptp: Added a clock that uses the Linux system time.
  ptp: Added a clock that uses the eTSEC found on the MPC85xx.

 Documentation/powerpc/dts-bindings/fsl/tsec.txt |   56 +++
 Documentation/ptp/ptp.txt                       |   95 ++++
 Documentation/ptp/testptp.c                     |  245 +++++++++++
 Documentation/ptp/testptp.mk                    |   33 ++
 arch/powerpc/boot/dts/mpc8313erdb.dts           |   14 +
 arch/powerpc/boot/dts/p2020ds.dts               |   14 +
 arch/powerpc/boot/dts/p2020rdb.dts              |   14 +
 drivers/Kconfig                                 |    2 +
 drivers/Makefile                                |    1 +
 drivers/net/Makefile                            |    1 +
 drivers/net/gianfar_ptp.c                       |  521 +++++++++++++++++++++++
 drivers/net/gianfar_ptp_reg.h                   |  113 +++++
 drivers/ptp/Kconfig                             |   51 +++
 drivers/ptp/Makefile                            |    6 +
 drivers/ptp/ptp_clock.c                         |  512 ++++++++++++++++++++++
 drivers/ptp/ptp_linux.c                         |  136 ++++++
 include/linux/Kbuild                            |    1 +
 include/linux/ptp_clock.h                       |   79 ++++
 include/linux/ptp_clock_kernel.h                |  137 ++++++
 kernel/time/ntp.c                               |    2 +
 20 files changed, 2033 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/ptp/ptp.txt
 create mode 100644 Documentation/ptp/testptp.c
 create mode 100644 Documentation/ptp/testptp.mk
 create mode 100644 drivers/net/gianfar_ptp.c
 create mode 100644 drivers/net/gianfar_ptp_reg.h
 create mode 100644 drivers/ptp/Kconfig
 create mode 100644 drivers/ptp/Makefile
 create mode 100644 drivers/ptp/ptp_clock.c
 create mode 100644 drivers/ptp/ptp_linux.c
 create mode 100644 include/linux/ptp_clock.h
 create mode 100644 include/linux/ptp_clock_kernel.h

