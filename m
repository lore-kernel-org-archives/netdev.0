From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH v2 0/7] net: mvneta: Switch to per-CPU irq and make rxq_def useful
Date: Fri, 25 Sep 2015 18:09:31 +0200
Message-ID: <1443197378-30717-1-git-send-email-gregory.clement@free-electrons.com>
Cc: Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Maxime Ripard <maxime.ripard@free-electrons.com>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Willy Tarreau <w@1wt.eu>, linux-arm-kernel@lists.infradead.org
To: Thomas Gleixner <tglx@linutronix.de>,
	Jason Cooper <jason@lakedaemon.net>,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

As stated in the first version: "this patchset reworks the Marvell
neta driver in order to really support its per-CPU interrupts, instead
of faking them as SPI, and allow the use of any RX queue instead of
the hardcoded RX queue 0 that we have currently."

Following the review which has been done, Maxime started adding the
CPU hotplug support. I continued his work a few weeks ago and here is
the result.

Since the 1st version the main change is this CPU hotplug support, in
order to validate it I powered up and down the CPUs while performing
iperf. I ran the tests during hours: the kernel didn't crash and the
network interfaces were still usable. Of course it impacted the
performance, but continuously power down and up the CPUs is not
something we usually do.

I also reorganized the series, the 3 first patches should go through
the irq subsystem, whereas the 4 others should go to the network
subsystem.

However, there is a runtime dependency between the two parts. Patch 5
depend on the patch 3 to be able to use the percpu irq.

Thanks,

Gregory

PS: Thanks to Willy who gave me some pointers on how to deal with the
NAPI.

Maxime Ripard (7):
  genirq: Fix the documentation of request_percpu_irq
  irq: Export per-cpu irq allocation and de-allocation functions
  irqchip: armada-370-xp: Rework per-cpu interrupts handling
  net: mvneta: Fix CPU_MAP registers initialisation
  net: mvneta: Handle per-cpu interrupts
  net: mvneta: Allow different queues
  net: mvneta: Statically assign queues to CPUs

 drivers/irqchip/irq-armada-370-xp.c   |  14 +-
 drivers/net/ethernet/marvell/mvneta.c | 316 +++++++++++++++++++++++-----------
 kernel/irq/manage.c                   |   9 +-
 3 files changed, 226 insertions(+), 113 deletions(-)

-- 
2.1.0
