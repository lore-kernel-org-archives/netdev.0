From: Anna-Maria Gleixner <anna-maria@linutronix.de>
Subject: [PATCH] net: mvneta: Remove superfluous SMP function call
Date: Mon,  4 Apr 2016 11:20:39 +0200
Message-ID: <1459761639-176299-1-git-send-email-anna-maria@linutronix.de>
Cc: rt@linutronix.de, Anna-Maria Gleixner <anna-maria@linutronix.de>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since commit 1cf4f629d9d2 ("cpu/hotplug: Move online calls to
hotplugged cpu") it is ensured that callbacks of CPU_ONLINE and
CPU_DOWN_PREPARE are processed on the hotplugged cpu. Due to this SMP
function calls are no longer required.

Replace smp_call_function_single() with a direct call to
mvneta_percpu_enable() or mvneta_percpu_disable(). The functions do
not require to be called with interrupts disabled, therefore the
smp_call_function_single() calling convention is not preserved.

Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Anna-Maria Gleixner <anna-maria@linutronix.de>
---
 drivers/net/ethernet/marvell/mvneta.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -3354,8 +3354,7 @@ static int mvneta_percpu_notifier(struct
 		/* Enable per-CPU interrupts on the CPU that is
 		 * brought up.
 		 */
-		smp_call_function_single(cpu, mvneta_percpu_enable,
-					 pp, true);
+		mvneta_percpu_enable(pp);
 
 		/* Enable per-CPU interrupt on the one CPU we care
 		 * about.
@@ -3387,8 +3386,7 @@ static int mvneta_percpu_notifier(struct
 		/* Disable per-CPU interrupts on the CPU that is
 		 * brought down.
 		 */
-		smp_call_function_single(cpu, mvneta_percpu_disable,
-					 pp, true);
+		mvneta_percpu_disable(pp);
 
 		break;
 	case CPU_DEAD:
