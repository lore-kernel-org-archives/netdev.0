From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 0/2] IRQ affinity reverse-mapping
Date: Tue, 04 Jan 2011 19:37:22 +0000
Message-ID: <1294169842.3636.31.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series is intended to support queue selection on multiqueue
IRQ-per-queue network devices (accelerated RFS and XPS-MQ) and
potentially queue selection for other classes of multiqueue device.

The first patch implements IRQ affinity notifiers, based on the outline
that Thomas wrote in response to my earlier patch series for accelerated RFS.

The second patch is a generalisation of the CPU affinity reverse-
mapping, plus functions to maintain such a mapping based on the new IRQ
affinity notifiers.

I would like to be able to use this functionality in networking for
2.6.38.  Thomas, if you are happy with this, could these changes go
through net-next-2.6?  Alternately, if Linus pulls from linux-2.6-tip
and David pulls from Linus during the merge window, I can (re-)submit
the dependent changes after that.

Ben.

Ben Hutchings (2):
  genirq: Add IRQ affinity notifiers
  lib: cpu_rmap: CPU affinity reverse-mapping

 include/linux/cpu_rmap.h  |   73 +++++++++++++
 include/linux/interrupt.h |   41 +++++++
 include/linux/irqdesc.h   |    3 +
 kernel/irq/manage.c       |   81 ++++++++++++++
 lib/Kconfig               |    4 +
 lib/Makefile              |    2 +
 lib/cpu_rmap.c            |  262 +++++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 466 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/cpu_rmap.h
 create mode 100644 lib/cpu_rmap.c

-- 
1.7.3.4


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
