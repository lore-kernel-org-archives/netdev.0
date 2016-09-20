From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: [PATCH v2 0/2] make POSIX timers optional
Date: Tue, 20 Sep 2016 15:56:38 -0400
Message-ID: <1474401400-18491-1-git-send-email-nicolas.pitre@linaro.org>
Cc: Thomas Gleixner <tglx@linutronix.de>,
        Richard Cochran <richardcochran@gmail.com>,
        Josh Triplett <josh@joshtriplett.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: John Stultz <john.stultz@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Many embedded systems don't need the full POSIX timer support.
Configuring them out provides a nice kernel image size reduction.

When POSIX timers are configured out, the PTP clock subsystem should be
left out as well. However a bunch of ethernet drivers currently *select*
it in their Kconfig entries. Therefore some more tweaks were needed to
break that hard dependency for those drivers to still be configured in
if desired.

It was agreed that the best path upstream for those patches is via
John Stultz's timer tree.

Previous itterations of those patches and the discussion threads can be
found here:

  https://lkml.org/lkml/2016/9/14/992
  https://lkml.org/lkml/2016/9/14/803
  https://lkml.org/lkml/2016/9/8/793

Changes from v1:

- Add a warning for the case where PTP clock subsystem is modular and a
  driver providing a clock is built-in rather than silently ignoring it.
  Suggested by Jiri Benc.
- Added Eugenia Emantayev's reviewed-by tag.

diffstat:

 drivers/Makefile                                |   2 +-
 drivers/net/ethernet/adi/Kconfig                |   8 +-
 drivers/net/ethernet/amd/Kconfig                |   2 +-
 drivers/net/ethernet/amd/xgbe/xgbe-main.c       |   6 +-
 drivers/net/ethernet/broadcom/Kconfig           |   4 +-
 drivers/net/ethernet/cavium/Kconfig             |   2 +-
 drivers/net/ethernet/freescale/Kconfig          |   2 +-
 drivers/net/ethernet/intel/Kconfig              |  10 +-
 drivers/net/ethernet/intel/e1000e/ptp.c         |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_ptp.c      |   2 +-
 drivers/net/ethernet/intel/igb/igb_ptp.c        |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c    |   2 +-
 drivers/net/ethernet/mellanox/mlx4/Kconfig      |   2 +-
 drivers/net/ethernet/mellanox/mlx4/en_clock.c   |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig |   2 +-
 .../net/ethernet/mellanox/mlx5/core/en_clock.c  |   2 +-
 drivers/net/ethernet/renesas/Kconfig            |   2 +-
 drivers/net/ethernet/samsung/Kconfig            |   2 +-
 drivers/net/ethernet/sfc/Kconfig                |   2 +-
 drivers/net/ethernet/sfc/ptp.c                  |  14 +--
 drivers/net/ethernet/stmicro/stmmac/Kconfig     |   2 +-
 .../net/ethernet/stmicro/stmmac/stmmac_ptp.c    |   2 +-
 drivers/net/ethernet/ti/Kconfig                 |   2 +-
 drivers/net/ethernet/tile/Kconfig               |   2 +-
 drivers/ptp/Kconfig                             |  14 ++-
 include/linux/posix-timers.h                    |  28 ++++-
 include/linux/ptp_clock_kernel.h                |  64 +++++++---
 include/linux/sched.h                           |  10 ++
 init/Kconfig                                    |  17 +++
 kernel/signal.c                                 |   4 +
 kernel/time/Kconfig                             |   1 +
 kernel/time/Makefile                            |  10 +-
 kernel/time/posix-stubs.c                       | 118 ++++++++++++++++++
 33 files changed, 282 insertions(+), 64 deletions(-)
