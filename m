From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 1/3] irq: Export irq_set_affinity() for drivers
Date: Tue, 20 Oct 2009 19:26:53 -0700
Message-ID: <20091021022626.32449.73883.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: gospo@redhat.com, netdev@vger.kernel.org,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta12.emeryville.ca.mail.comcast.net ([76.96.27.227]:52317
	"EHLO QMTA12.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751182AbZJUC34 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 22:29:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

This patch allows drivers to specify an IRQ affinity mask for
their respective interrupt sources.  This is very useful on
network adapters using MSI-X, where aligning network flows
linearly to CPUs greatly improves efficiency of the network
stack.

Today, users must either hand-set affinity through /proc, or
use a script through the same interface.  This patch will allow
a driver to come completely pre-canned with an optimal
configuration.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 kernel/irq/manage.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/kernel/irq/manage.c b/kernel/irq/manage.c
index bde4c66..185eb26 100644
--- a/kernel/irq/manage.c
+++ b/kernel/irq/manage.c
@@ -137,6 +137,7 @@ int irq_set_affinity(unsigned int irq, const struct cpumask *cpumask)
 	spin_unlock_irqrestore(&desc->lock, flags);
 	return 0;
 }
+EXPORT_SYMBOL(irq_set_affinity);
 
 #ifndef CONFIG_AUTO_IRQ_AFFINITY
 /*

