From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 0/2] [RFC] posix clock tuning
Date: Fri, 3 Sep 2010 11:27:59 +0200
Message-ID: <cover.1283504065.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Recently on the lkml, we discussed how to allow adjustment of posix
clocks. I have tried to understand and implement the ideas expressed
in the various threads.

If there is agreement on this approach, I will resubmit these two
patches as part of a longer series, including support for a new kind
of hardware clock, so you can see how it all fits together. But first,
I would like to concentrate on the new syscall itself.

The patches are against a recent net-next tree. Please don't worry if
the syscall tables are not quite up to date. I can fix that later.

Thanks,
Richard


Richard Cochran (2):
  posix clocks: introduce a syscall for clock tuning.
  posix clocks: introduce a sysfs presence.

 Documentation/ABI/testing/sysfs-timesource |   24 +++++
 arch/arm/include/asm/unistd.h              |    1 +
 arch/arm/kernel/calls.S                    |    1 +
 arch/blackfin/include/asm/unistd.h         |    3 +-
 arch/blackfin/mach-common/entry.S          |    1 +
 arch/powerpc/include/asm/systbl.h          |    1 +
 arch/powerpc/include/asm/unistd.h          |    3 +-
 arch/x86/ia32/ia32entry.S                  |    1 +
 arch/x86/include/asm/unistd_32.h           |    3 +-
 arch/x86/include/asm/unistd_64.h           |    2 +
 arch/x86/kernel/syscall_table_32.S         |    1 +
 drivers/char/mmtimer.c                     |    1 +
 include/linux/posix-timers.h               |   14 +++-
 include/linux/syscalls.h                   |    2 +
 include/linux/time.h                       |    2 +
 include/linux/timex.h                      |    3 +-
 kernel/compat.c                            |  136 ++++++++++++++++++----------
 kernel/posix-cpu-timers.c                  |    6 ++
 kernel/posix-timers.c                      |   98 +++++++++++++++++++--
 19 files changed, 243 insertions(+), 60 deletions(-)
 create mode 100644 Documentation/ABI/testing/sysfs-timesource
