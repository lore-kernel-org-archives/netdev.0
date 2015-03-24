From: <cmetcalf@ezchip.com>
Subject: [PATCH 0/4] initial NOHZ_FULL support for tile
Date: Tue, 24 Mar 2015 15:21:31 -0400
Message-ID: <1427224895-30830-1-git-send-email-cmetcalf@ezchip.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chris Metcalf <cmetcalf@ezchip.com>
To: <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Borislav Petkov <bp@alien8.de>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Gilad Ben-Yossef <gilad@benyossef.com>,
	"H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>,
	Kevin Hilman <khilman@linaro.org>,
	Li Zhong <zhong@linux.vnet.ibm.com>,
	Mike Galbraith <efault@gmx.de>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Thomas Gleixner <tglx@linutronix.de>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Metcalf <cmetcalf@ezchip.com>

These changes are the necessary minimum to make the tile architecture
work relatively well with NOHZ_FULL.  The tile architecture has had
out-of-tree support since 2008 for a DATAPLANE mode that provided
similar functionality (called Zero-Overhead Linux in our marketing
materials); we are now in the process of layering that on top of the
community NOHZ_FULL to upstream it.

Chris Metcalf (4):
  tile: support arch_irq_work_raise
  tile: support CONTEXT_TRACKING and thus NOHZ_FULL
  nohz: add tick_nohz_full_clear_cpus() API
  net: tile: don't send interrupts to nohz cores by default

 arch/tile/Kconfig                   |  1 +
 arch/tile/include/asm/Kbuild        |  1 -
 arch/tile/include/asm/irq_work.h    | 14 ++++++++++++++
 arch/tile/include/asm/smp.h         |  1 +
 arch/tile/include/asm/thread_info.h |  9 ++++++---
 arch/tile/kernel/process.c          | 12 ++++++++----
 arch/tile/kernel/ptrace.c           | 22 ++++++++++++++++++++--
 arch/tile/kernel/single_step.c      |  3 +++
 arch/tile/kernel/smp.c              | 32 +++++++++++++++++++++++++++++++-
 arch/tile/kernel/traps.c            | 16 +++++++++-------
 arch/tile/kernel/unaligned.c        | 22 +++++++++++++---------
 arch/tile/mm/fault.c                | 10 +++++++---
 drivers/net/ethernet/tile/tilegx.c  |  5 ++++-
 include/linux/tick.h                |  7 +++++++
 14 files changed, 124 insertions(+), 31 deletions(-)
 create mode 100644 arch/tile/include/asm/irq_work.h

-- 
2.1.2
