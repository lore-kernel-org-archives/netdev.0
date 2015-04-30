From: Baolin Wang <baolin.wang@linaro.org>
Subject: [PATCH v2 00/15] Convert the posix_clock_operations and k_clock structure to ready for 2038
Date: Thu, 30 Apr 2015 16:06:25 +0800
Message-ID: <1430381185-26191-1-git-send-email-baolin.wang@linaro.org>
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
	baolin.wang@linaro.org, y2038@lists.linaro.org
To: tglx@linutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series changes the 32-bit time type (timespec/itimerspec) to the 64-bit one
(timespec64/itimerspec64), since 32-bit time types will break in the year 2038.

This patch series introduces new methods with timespec64/itimerspec64 type,
and removes the old ones with timespec/itimerspec type for posix_clock_operations
and k_clock structure.

Also introduces some new functions with timespec64/itimerspec64 type, like current_kernel_time64(),
hrtimer_get_res64(), cputime_to_timespec64() and timespec64_to_cputime().

Changes since V1:
	-Split some patch into small patch.
	-Change the methods for converting the syscall and add some default function for new 64bit methods for syscall function.
	-Introduce the new function do_sys_settimeofday64() and move do_sys_settimeofday() function to head file.
	-Modify the EXPORT_SYMPOL issue.
	-Add new 64bit methods in cputime_nsecs.h file.
	-Modify some patch logs.

Baolin Wang (15):
  linux/time64.h:Introduce the 'struct itimerspec64' for 64bit
  timekeeping:Introduce the current_kernel_time64() function with
    timespec64 type
  time/hrtimer:Introduce hrtimer_get_res64() with timespec64 type for
    getting the timer resolution
  posix timers:Introduce the 64bit methods with timespec64 type for
    k_clock structure
  posix-timers:Split out the guts of the syscall and change the
    implementation
  posix-timers:Convert to the 64bit methods for the syscall function
  time:Introduce the do_sys_settimeofday64() function with timespec64
    type
  time/posix-timers:Convert to the 64bit methods for k_clock callback
    functions
  char/mmtimer:Convert to the 64bit methods for k_clock callback
    function
  time/alarmtimer:Convert to the new methods for k_clock structure
  time/posix-clock:Convert to the 64bit methods for k_clock and
    posix_clock_operations structure
  time/time:Introduce the timespec64_to_jiffies/jiffies_to_timespec64
    function
  cputime:Introduce the cputime_to_timespec64/timespec64_to_cputime
    function
  time/posix-cpu-timers:Convert to the 64bit methods for k_clock
    structure
  k_clock:Remove the 32bit methods with timespec/itimerspec type

 arch/powerpc/include/asm/cputime.h    |    6 +-
 arch/s390/include/asm/cputime.h       |    8 +-
 drivers/char/mmtimer.c                |   36 +++--
 drivers/ptp/ptp_clock.c               |   26 +---
 include/asm-generic/cputime_jiffies.h |   10 +-
 include/asm-generic/cputime_nsecs.h   |    4 +-
 include/linux/cputime.h               |   15 ++
 include/linux/hrtimer.h               |   12 +-
 include/linux/jiffies.h               |   21 ++-
 include/linux/posix-clock.h           |   10 +-
 include/linux/posix-timers.h          |   18 +--
 include/linux/time64.h                |   35 +++++
 include/linux/timekeeping.h           |   26 +++-
 kernel/time/alarmtimer.c              |   43 +++---
 kernel/time/hrtimer.c                 |   10 +-
 kernel/time/posix-clock.c             |   20 +--
 kernel/time/posix-cpu-timers.c        |   83 +++++-----
 kernel/time/posix-timers.c            |  269 ++++++++++++++++++++++-----------
 kernel/time/time.c                    |   22 +--
 kernel/time/timekeeping.c             |    6 +-
 kernel/time/timekeeping.h             |    2 +-
 21 files changed, 428 insertions(+), 254 deletions(-)

-- 
1.7.9.5
