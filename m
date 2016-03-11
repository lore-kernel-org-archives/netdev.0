From: Anna-Maria Gleixner <anna-maria@linutronix.de>
Subject: [PATCH] net: mvneta: Add missing hotplug notifier transition
Date: Fri, 11 Mar 2016 10:10:23 +0100
Message-ID: <1457687423-39784-1-git-send-email-anna-maria@linutronix.de>
Cc: rt@linutronix.de, Anna-Maria Gleixner <anna-maria@linutronix.de>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The mvneta_percpu_notifier() hotplug callback lacks handling of the
CPU_DOWN_FAILED case. That means, if CPU_DOWN_PREPARE failes, the
driver is not well configured on the CPU.

Add handling for CPU_DOWN_FAILED[_FROZEN] hotplug notifier transition
to setup the driver.

Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Anna-Maria Gleixner <anna-maria@linutronix.de>
---
 drivers/net/ethernet/marvell/mvneta.c |    2 ++
 1 file changed, 2 insertions(+)

--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -2920,6 +2920,8 @@ static int mvneta_percpu_notifier(struct
 	switch (action) {
 	case CPU_ONLINE:
 	case CPU_ONLINE_FROZEN:
+	case CPU_DOWN_FAILED:
+	case CPU_DOWN_FAILED_FROZEN:
 		spin_lock(&pp->lock);
 		/* Configuring the driver for a new CPU while the
 		 * driver is stopping is racy, so just avoid it.
