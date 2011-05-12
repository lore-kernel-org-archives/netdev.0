From: Stephen Boyd <sboyd@codeaurora.org>
Subject: [PATCH 0/9] strict user copy checks on x86_64
Date: Thu, 12 May 2011 16:50:03 -0700
Message-ID: <1305244212-19183-1-git-send-email-sboyd@codeaurora.org>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Intel Linux Wireless <ilw@linux.intel.com>,
	linux-scsi@vger.kernel.org, x86@kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It turns out that strict user copy checks (also known as
CONFIG_DEBUG_STRICT_USER_COPY_CHECKS) isn't actually implemented
on x86_64 and thus we aren't catching potential security holes
at compile time.

This series adds support for strict user copy checks on x86_64
and silences all the benign warnings in the x86_64 allyesconfig.

The final patch consolidates the config option as its duplicated
across mutliple arches. I don't know what tree this series should
go through so I tried to send the individual driver patches to the
respective maintainers.

Stephen Boyd (9):
  iwlegacy: Silence DEBUG_STRICT_USER_COPY_CHECKS=y warning
  iwlwifi: Silence DEBUG_STRICT_USER_COPY_CHECKS=y warning
  [SCSI] lpfc: Silence DEBUG_STRICT_USER_COPY_CHECKS=y warning
  debugfs: Silence DEBUG_STRICT_USER_COPY_CHECKS=y warning
  kprobes: Silence DEBUG_STRICT_USER_COPY_CHECKS=y warning
  Bluetooth: Silence DEBUG_STRICT_USER_COPY_CHECKS=y warning
  ASoC: Silence DEBUG_STRICT_USER_COPY_CHECKS=y warning
  x86: Implement strict user copy checks for x86_64
  Consolidate CONFIG_DEBUG_STRICT_USER_COPY_CHECKS

 arch/parisc/Kconfig                         |    1 +
 arch/parisc/Kconfig.debug                   |   14 --------------
 arch/s390/Kconfig                           |    1 +
 arch/s390/Kconfig.debug                     |   14 --------------
 arch/s390/lib/Makefile                      |    1 -
 arch/s390/lib/usercopy.c                    |    8 --------
 arch/sparc/lib/Makefile                     |    1 -
 arch/sparc/lib/usercopy.c                   |    8 --------
 arch/tile/Kconfig                           |    8 +-------
 arch/tile/include/asm/uaccess.h             |    7 ++++++-
 arch/tile/lib/uaccess.c                     |    8 --------
 arch/x86/Kconfig                            |    1 +
 arch/x86/Kconfig.debug                      |   14 --------------
 arch/x86/include/asm/uaccess_64.h           |   12 +++++++++---
 arch/x86/lib/usercopy_32.c                  |    6 ------
 drivers/net/wireless/iwlegacy/iwl-4965-rs.c |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c   |    2 +-
 drivers/scsi/lpfc/lpfc_debugfs.c            |    3 ++-
 fs/debugfs/file.c                           |    2 +-
 kernel/kprobes.c                            |    2 +-
 lib/Kconfig.debug                           |   18 ++++++++++++++++++
 lib/Makefile                                |    1 +
 lib/usercopy.c                              |    8 ++++++++
 net/bluetooth/rfcomm/sock.c                 |    3 ++-
 sound/soc/soc-core.c                        |    2 +-
 25 files changed, 55 insertions(+), 92 deletions(-)
 delete mode 100644 arch/s390/lib/usercopy.c
 delete mode 100644 arch/sparc/lib/usercopy.c
 create mode 100644 lib/usercopy.c

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.
