From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 0/8][GIT PULL] time: Cross-timestamp infrastructure for 4.6
Date: Wed,  2 Mar 2016 20:21:51 -0800
Message-ID: <1456978919-30076-1-git-send-email-john.stultz@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: John Stultz <john.stultz@linaro.org>,
	Prarit Bhargava <prarit@redhat.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@kernel.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	kevin.b.stanton@intel.com, kevin.j.clarke@intel.com, hpa@zytor.com,
	netdev@vger.kernel.org
To: lkml <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey Thomas,
	So here is Christopher's cross-timestamp infrastructure
patchset which I wanted to send along for 4.6. These apply against
tip/timers/core.

Let me know if you have any objections.

thanks
-john

Cc: Prarit Bhargava <prarit@redhat.com>
Cc: Richard Cochran <richardcochran@gmail.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: kevin.b.stanton@intel.com
Cc: kevin.j.clarke@intel.com
Cc: hpa@zytor.com
Cc: jeffrey.t.kirsher@intel.com
Cc: netdev@vger.kernel.org


The following changes since commit 232d26373d310a941ef2ab46e53ea62fe076ed13:

  jiffies: Use CLOCKSOURCE_MASK instead of constant (2016-02-27 08:55:31 +0100)

are available in the git repository at:

  https://git.linaro.org/people/john.stultz/linux.git fortglx/4.6/time

for you to fetch changes up to dbfa7fb88d3ab62268b36ee26b2987a01f72a6c9:

  net: e1000e: Adds hardware supported cross timestamp on e1000e nic (2016-03-02 17:44:58 -0800)

----------------------------------------------------------------
Christopher S. Hall (8):
  time: Add cycles to nanoseconds translation
  time: Add timekeeping snapshot code capturing system time and counter
  time: Remove duplicated code in ktime_get_raw_and_real()
  time: Add driver cross timestamp interface for higher precision time
    synchronization
  time: Add history to cross timestamp interface supporting slower
    devices
  x86: tsc: Always Running Timer (ART) correlated clocksource
  ptp: Add PTP_SYS_OFFSET_PRECISE for driver crosstimestamping
  net: e1000e: Adds hardware supported cross timestamp on e1000e nic

 Documentation/ptp/testptp.c                 |   6 +-
 arch/x86/include/asm/cpufeature.h           |   2 +-
 arch/x86/include/asm/tsc.h                  |   2 +
 arch/x86/kernel/tsc.c                       |  62 ++++++
 drivers/net/ethernet/intel/Kconfig          |   9 +
 drivers/net/ethernet/intel/e1000e/defines.h |   5 +
 drivers/net/ethernet/intel/e1000e/ptp.c     |  85 +++++++++
 drivers/net/ethernet/intel/e1000e/regs.h    |   4 +
 drivers/ptp/ptp_chardev.c                   |  27 +++
 include/linux/pps_kernel.h                  |  17 +-
 include/linux/ptp_clock_kernel.h            |   8 +
 include/linux/timekeeper_internal.h         |   2 +
 include/linux/timekeeping.h                 |  58 ++++++
 include/uapi/linux/ptp_clock.h              |  13 +-
 kernel/time/timekeeping.c                   | 286 +++++++++++++++++++++++++---
 15 files changed, 546 insertions(+), 40 deletions(-)

-- 
1.9.1
