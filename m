From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH v2 1/7] genirq: Fix the documentation of request_percpu_irq
Date: Fri, 25 Sep 2015 18:09:32 +0200
Message-ID: <1443197378-30717-2-git-send-email-gregory.clement@free-electrons.com>
References: <1443197378-30717-1-git-send-email-gregory.clement@free-electrons.com>
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
In-Reply-To: <1443197378-30717-1-git-send-email-gregory.clement@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Maxime Ripard <maxime.ripard@free-electrons.com>

The documentation of request_percpu_irq is confusing and suggest that the
interrupt is not enabled at all, while it is actually enabled on the local
CPU.

Clarify that.

Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>
Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
---
 kernel/irq/manage.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/kernel/irq/manage.c b/kernel/irq/manage.c
index ad1b064f94fe..dc8a80ecfc4a 100644
--- a/kernel/irq/manage.c
+++ b/kernel/irq/manage.c
@@ -1790,9 +1790,10 @@ int setup_percpu_irq(unsigned int irq, struct irqaction *act)
  *	@devname: An ascii name for the claiming device
  *	@dev_id: A percpu cookie passed back to the handler function
  *
- *	This call allocates interrupt resources, but doesn't
- *	automatically enable the interrupt. It has to be done on each
- *	CPU using enable_percpu_irq().
+ *	This call allocates interrupt resources and enables the
+ *	interrupt on the local CPU. If the interrupt is supposed to be
+ *	enabled on other CPUs, it has to be done on each CPU using
+ *	enable_percpu_irq().
  *
  *	Dev_id must be globally unique. It is a per-cpu variable, and
  *	the handler gets called with the interrupted CPU's instance of
-- 
2.1.0
