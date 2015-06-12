From: Baolin Wang <baolin.wang@linaro.org>
Subject: [PATCH v5 00/24] Convert the posix_clock_operations and k_clock structure to ready for 2038
Date: Fri, 12 Jun 2015 15:19:47 +0800
Message-ID: <cover.1434079262.git.baolin.wang@linaro.org>
References: <lfywpz1987>
Cc: arnd@arndb.de, john.stultz@linaro.org, heenasirwani@gmail.com,
	pang.xunlei@linaro.org, peterz@infradead.org,
	rafael.j.wysocki@intel.com, gregkh@linuxfoundation.org,
	richardcochran@gmail.com, benh@kernel.crashing.org,
	paulus@samba.org, mpe@ellerman.id.au, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, linux390@de.ibm.com, rth@twiddle.net,
	riel@redhat.com, cl@linux.com, tj@kernel.org, fweisbec@gmail.com,
	ahh@google.com, pjt@google.com, linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, james.l.morris@oracle.com,
	serge@hallyn.com, pmoore@redhat.com, tiwai@suse.de,
	jeffv@google.com, jlayton@primarydata.com, keescook@chromium.org,
	sds@tycho.nsa.gov, mark.d.rustad@intel.com,
	linux-security-module@vger.kernel.org, baolin.wang@linaro.org,
	y2038@lists.linaro
To: tglx@linutronix.de
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <lfywpz1987>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series changes the 32-bit time types (timespec/itimerspec) to
the 64-bit types (timespec64/itimerspec64), since 32-bit time types will
break in the year 2038 on 32bit systems.

This patch series introduces new methods with timespec64/itimerspec64 type,
and removes the old ones with timespec/itimerspec type for posix_clock_operations
and k_clock structure.

---
Changes since v4:
- Rebase the patch series.
- Modify the subject line and the changelog.

Changes since v3:
- Fix some introducing bugs.

Changes since v2:
- Split the syscall conversion patch into small some patches.

Changes since V1:
- Split some patch into small patch.
- Add some default function for new 64bit methods for syscall function.
- Move do_sys_settimeofday() function to head file.
- Modify the EXPORT_SYMPOL issue.
- Add new 64bit methods in cputime_nsecs.h file.
---

Baolin Wang (24):
  time: Introduce struct itimerspec64
  timekeeping: Introduce current_kernel_time64()
  security: Introduce security_settime64()
  time: Introduce do_sys_settimeofday64()
  posix-timers: Introduce {get,put}_timespec and {get,put}_itimerspec
  posix-timers: Factor out the guts of 'timer_gettime'
  posix-timers: Implement y2038 safe timer_get64() callback
  posix-timers: Factor out the guts of 'timer_settime'
  posix-timers: Implement y2038 safe timer_set64() callback
  posix-timers: Factor out the guts of 'clock_settime'
  posix-timers: Implement y2038 safe clock_set64() callback
  posix-timers: Factor out the guts of 'clock_gettime'
  posix-timers: Implement y2038 safe clock_get64() callback
  posix-timers: Factor out the guts of 'clcok_getres'
  posix-timers: Implement y2038 safe clock_getres64() callback
  timekeeping: Change the implementation of timekeeping_clocktai()
  posix-timers: Convert to y2038 safe callbacks
  mmtimer: Convert to y2038 safe callbacks
  alarmtimer: Convert to y2038 safe callbacks
  posix-clock: Convert to y2038 safe callbacks
  time: Introduce timespec64_to_jiffies()/jiffies_to_timespec64()
  cputime: Introduce cputime_to_timespec64()/timespec64_to_cputime()
  posix-cpu-timers: Convert to y2038 safe callbacks
  k_clock: Remove y2038 unsafe callbacks

 arch/powerpc/include/asm/cputime.h    |    6 +-
 arch/s390/include/asm/cputime.h       |    8 +-
 drivers/char/mmtimer.c                |   36 +++--
 drivers/ptp/ptp_clock.c               |   22 +--
 include/asm-generic/cputime_jiffies.h |   10 +-
 include/asm-generic/cputime_nsecs.h   |    6 +-
 include/linux/cputime.h               |   16 ++
 include/linux/jiffies.h               |   21 ++-
 include/linux/lsm_hooks.h             |    5 +-
 include/linux/posix-clock.h           |   10 +-
 include/linux/posix-timers.h          |   18 +--
 include/linux/security.h              |   20 ++-
 include/linux/time64.h                |   35 +++++
 include/linux/timekeeping.h           |   25 +++-
 kernel/time/alarmtimer.c              |   38 ++---
 kernel/time/posix-clock.c             |   20 +--
 kernel/time/posix-cpu-timers.c        |   84 ++++++-----
 kernel/time/posix-timers.c            |  257 +++++++++++++++++++++------------
 kernel/time/time.c                    |   19 +--
 kernel/time/timekeeping.c             |    6 +-
 security/commoncap.c                  |    2 +-
 security/security.c                   |    2 +-
 22 files changed, 412 insertions(+), 254 deletions(-)

-- 
1.7.9.5
