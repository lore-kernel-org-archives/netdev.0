From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: [PATCH 0/4] make POSIX timers optional with some Kconfig help
Date: Wed, 19 Oct 2016 19:42:49 -0400
Message-ID: <1476920573-14384-1-git-send-email-nicolas.pitre@linaro.org>
Cc: Thomas Gleixner <tglx@linutronix.de>,
        Josh Triplett <josh@joshtriplett.org>, netdev@vger.kernel.org,
        linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org
To: John Stultz <john.stultz@linaro.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Yann E MORIN <yann.morin.1998@free.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Many embedded systems don't need the full POSIX timer support.
Configuring them out provides a nice kernel image size reduction.

When POSIX timers are configured out, the PTP clock subsystem should be
left out as well. However a bunch of ethernet drivers currently *select*
the later in their Kconfig entries. Therefore some more work was needed
to break that hard dependency from those drivers without preventing their
usage altogether.

Therefore this series also includes kconfig changes to implement a new
keyword to express some reverse dependencies like "select" does, named
"imply", and still allowing for the target config symbol to be disabled
if the user or a direct dependency says so.

How to deal with the dependencies across three subsystems for potential
upstream merging needs to be figured out.

The bulk of the diffstat comes from the kconfig lex parser regeneration.

diffstat:

 Documentation/kbuild/kconfig-language.txt       |   28 +
 drivers/Makefile                                |    2 +-
 drivers/net/ethernet/adi/Kconfig                |    2 +-
 drivers/net/ethernet/amd/Kconfig                |    2 +-
 drivers/net/ethernet/amd/xgbe/xgbe-main.c       |    6 +-
 drivers/net/ethernet/broadcom/Kconfig           |    4 +-
 drivers/net/ethernet/cavium/Kconfig             |    2 +-
 drivers/net/ethernet/freescale/Kconfig          |    2 +-
 drivers/net/ethernet/intel/Kconfig              |   10 +-
 drivers/net/ethernet/mellanox/mlx4/Kconfig      |    2 +-
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig |    2 +-
 drivers/net/ethernet/renesas/Kconfig            |    2 +-
 drivers/net/ethernet/samsung/Kconfig            |    2 +-
 drivers/net/ethernet/sfc/Kconfig                |    2 +-
 drivers/net/ethernet/stmicro/stmmac/Kconfig     |    2 +-
 drivers/net/ethernet/ti/Kconfig                 |    2 +-
 drivers/net/ethernet/tile/Kconfig               |    2 +-
 drivers/ptp/Kconfig                             |   10 +-
 include/linux/posix-timers.h                    |   28 +-
 include/linux/ptp_clock_kernel.h                |   65 +-
 include/linux/sched.h                           |   10 +
 init/Kconfig                                    |   17 +
 kernel/signal.c                                 |    4 +
 kernel/time/Makefile                            |   10 +-
 kernel/time/posix-stubs.c                       |  118 ++
 scripts/kconfig/expr.h                          |    2 +
 scripts/kconfig/menu.c                          |   55 +-
 scripts/kconfig/symbol.c                        |   26 +-
 scripts/kconfig/zconf.gperf                     |    1 +
 scripts/kconfig/zconf.hash.c_shipped            |   30 +-
 scripts/kconfig/zconf.tab.c_shipped             | 1581 ++++++++---------
 scripts/kconfig/zconf.y                         |   16 +-
 32 files changed, 1115 insertions(+), 932 deletions(-)
