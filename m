From: Baolin Wang <baolin.wang@linaro.org>
Subject: [PATCH v4 00/25] Convert the posix_clock_operations and k_clock structure to ready for 2038
Date: Mon,  1 Jun 2015 19:44:53 +0800
Message-ID: <1433159093-4548-1-git-send-email-baolin.wang@linaro.org>
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
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series changes the 32-bit time types (timespec/itimerspec) to
the 64-bit types (timespec64/itimerspec64), since 32-bit time types will
break in the year 2038.

This patch series introduces new methods with timespec64/itimerspec64 type,
and removes the old ones with timespec/itimerspec type for posix_clock_operations
and k_clock structure.

Baolin Wang (25):
  time:Introduce struct itimerspec64
  timekeeping:Introduce the current_kernel_time64()
  hrtimer:Introduce hrtimer_get_res64()
  security: Introduce security_settime64()
  time:Introduce the do_sys_settimeofday64()
  posix-timers:Introduce {get,put}_timespec/{get,put}_itimerspec
  posix-timers: Split up timer_gettime()/timer_settime()/clock_settime()/
    clock_gettime()/clock_getres().
  posix-timers: Convert timer_gettime()/timer_settime()/clock_settime()/
    clock_gettime()/clock_getres() to timespec64/itimerspec64.
  mmtimer:Convert to timespec64/itimerspec64
  alarmtimer:Convert to timespec64/itimerspec64
  posix-clock:Convert to timespec64/itimerspec64
  time:Introduce timespec64_to_jiffies()/jiffies_to_timespec64()
  cputime:Introduce cputime_to_timespec64()/timespec64_to_cputime()
  posix-cpu-timers:Convert to timespec64/itimerspec64
  k_clock:Remove timespec/itimerspec

 arch/powerpc/include/asm/cputime.h    |    6 +-
 arch/s390/include/asm/cputime.h       |    8 +-
 drivers/char/mmtimer.c                |   36 +++--
 drivers/ptp/ptp_clock.c               |   26 +---
 include/asm-generic/cputime_jiffies.h |   10 +-
 include/asm-generic/cputime_nsecs.h   |    4 +-
 include/linux/cputime.h               |   16 ++
 include/linux/hrtimer.h               |   16 +-
 include/linux/jiffies.h               |   21 ++-
 include/linux/posix-clock.h           |   10 +-
 include/linux/posix-timers.h          |   18 +--
 include/linux/security.h              |   25 +++-
 include/linux/time64.h                |   35 +++++
 include/linux/timekeeping.h           |   26 +++-
 kernel/time/alarmtimer.c              |   43 +++---
 kernel/time/hrtimer.c                 |   10 +-
 kernel/time/posix-clock.c             |   20 +--
 kernel/time/posix-cpu-timers.c        |   84 ++++++-----
 kernel/time/posix-timers.c            |  259 +++++++++++++++++++++------------
 kernel/time/time.c                    |   20 +--
 kernel/time/timekeeping.c             |    6 +-
 kernel/time/timekeeping.h             |    1 -
 security/commoncap.c                  |    2 +-
 security/security.c                   |    2 +-
 24 files changed, 437 insertions(+), 267 deletions(-)

-- 
1.7.9.5

