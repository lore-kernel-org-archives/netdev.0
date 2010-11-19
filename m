From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [RFC][PATCH 0/5] RFS hardware acceleration (v2)
Date: Fri, 19 Nov 2010 18:42:56 +0000
Message-ID: <1290192176.2671.38.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series extends RFS to use hardware RX filters where
available.  Depending on the number of hardware RX queues and their
IRQs' affinity, this should reduce the need for IPIs or at least get
packets delivered to the right NUMA node.

The first patch implements IRQ affinity notifiers, based on the outline
that Thomas Gleixner wrote in response to the previous version of this
patch series.

The second patch is a generalisation of the CPU affinity reverse-
mapping, plus functions to maintain such a mapping based on the new IRQ
affinity notifiers.

The remaining patches add the RFS acceleration hooks and an
implementation in the sfc driver.  These are largely unchanged from the
previous version of this patch series; I haven't yet had the time to do
further tuning yet.  However I have done some more benchmarking and will
send some results in a separate follow-up to this.

Ben.

Ben Hutchings (5):
  genirq: Add IRQ affinity notifiers
  lib: cpu_rmap: CPU affinity reverse-mapping
  net: RPS: Enable hardware acceleration
  sfc: Limit filter search depth further for performance hints (i.e.
    RFS)
  sfc: Implement RFS acceleration

 drivers/net/sfc/Kconfig   |    4 +
 drivers/net/sfc/efx.c     |   66 ++++++++++--
 drivers/net/sfc/efx.h     |    9 ++
 drivers/net/sfc/filter.c  |  113 ++++++++++++++++++-
 include/linux/cpu_rmap.h  |   73 ++++++++++++
 include/linux/interrupt.h |   41 +++++++
 include/linux/irqdesc.h   |    3 +
 include/linux/netdevice.h |   31 +++++-
 kernel/irq/manage.c       |   81 +++++++++++++
 lib/Kconfig               |    4 +
 lib/Makefile              |    2 +
 lib/cpu_rmap.c            |  272 +++++++++++++++++++++++++++++++++++++++++++++
 net/Kconfig               |    1 +
 net/core/dev.c            |   89 ++++++++++++++-
 14 files changed, 767 insertions(+), 22 deletions(-)
 create mode 100644 include/linux/cpu_rmap.h
 create mode 100644 lib/cpu_rmap.c

-- 
1.7.3.2


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
