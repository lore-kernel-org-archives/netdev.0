From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: [PATCH 2/6] genirq: Fix the documentation of request_percpu_irq
Date: Fri,  3 Jul 2015 16:25:47 +0200
Message-ID: <1435933551-28696-3-git-send-email-maxime.ripard@free-electrons.com>
References: <1435933551-28696-1-git-send-email-maxime.ripard@free-electrons.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Maxime Ripard <maxime.ripard@free-electrons.com>
To: Thomas Gleixner <tglx@linutronix.de>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1435933551-28696-1-git-send-email-maxime.ripard@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The documentation of request_percpu_irq is confusing and suggest that the
interrupt is not enabled at all, while it is actually enabled on the local
CPU.

Clarify that.

Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>
---
 kernel/irq/manage.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/kernel/irq/manage.c b/kernel/irq/manage.c
index e68932bb308e..ec31697f29b3 100644
--- a/kernel/irq/manage.c
+++ b/kernel/irq/manage.c
@@ -1757,9 +1757,10 @@ int setup_percpu_irq(unsigned int irq, struct irqaction *act)
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
2.4.5
