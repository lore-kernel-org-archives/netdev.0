From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: (unknown)
Date: Tue, 25 Oct 2016 22:28:46 -0400
Message-ID: <1477448931-29051-1-git-send-email-nicolas.pitre@linaro.org>
Cc: Thomas Gleixner <tglx@linutronix.de>,
        Josh Triplett <josh@joshtriplett.org>,
        Edward Cree <ecree@solarflare.com>, netdev@vger.kernel.org,
        linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org
To: John Stultz <john.stultz@linaro.org>,
        Richard Cochran <richardcochran@gmail.com>,
        "Yann E. MORIN" <yann.morin.1998@free.fr>,
        Michal Marek <mmarek@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Subject: 
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: [PATCH v2 0/5] make POSIX timers optional with some Kconfig help

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
if the user or a direct dependency says so. The "suggest" keyword is
also provided to complement "imply" but without the restrictions from
"imply" or "select".

At this point I'd like to gather ACKs especially from people in the "To"
field. Ideally this would need to go upstream as a single series to avoid
cross subsystem dependency issues, and we should decide which maintainer
tree to use.  Suggestions welcome.

Changes from v1:

- added "suggest" to kconfig for completeness
- various typo fixes
- small "imply" effect visibility fix

The bulk of the diffstat comes from the kconfig lex parser regeneration.

Diffstat:

 Documentation/kbuild/kconfig-language.txt       |   34 +
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
 scripts/kconfig/expr.h                          |    4 +
 scripts/kconfig/menu.c                          |   68 +-
 scripts/kconfig/symbol.c                        |   42 +-
 scripts/kconfig/zconf.gperf                     |    2 +
 scripts/kconfig/zconf.hash.c_shipped            |  228 +--
 scripts/kconfig/zconf.tab.c_shipped             | 1631 ++++++++---------
 scripts/kconfig/zconf.y                         |   28 +-
 32 files changed, 1300 insertions(+), 1045 deletions(-)
