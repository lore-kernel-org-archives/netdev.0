From: Mark Einon <mark.einon@gmail.com>
Subject: [PATCH 6/8] staging: et131x: Rename NUM_PACKETS_HANDLED to
 MAX_PACKETS_HANDLED
Date: Wed, 20 Aug 2014 23:17:56 +0100
Message-ID: <1408573078-9320-7-git-send-email-mark.einon@gmail.com>
References: <1408573078-9320-1-git-send-email-mark.einon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, Mark Einon <mark.einon@gmail.com>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1408573078-9320-1-git-send-email-mark.einon@gmail.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

To better describe it's use as a hard limit.

Signed-off-by: Mark Einon <mark.einon@gmail.com>
---
 drivers/staging/et131x/et131x.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/et131x/et131x.c b/drivers/staging/et131x/et131x.c
index 551b250..df83ea3 100644
--- a/drivers/staging/et131x/et131x.c
+++ b/drivers/staging/et131x/et131x.c
@@ -179,7 +179,7 @@ MODULE_DESCRIPTION("10/100/1000 Base-T Ethernet Driver for the ET1310 by Agere S
 #define NIC_DEFAULT_NUM_RFD	1024
 #define NUM_FBRS		2
 
-#define NUM_PACKETS_HANDLED	256
+#define MAX_PACKETS_HANDLED	256
 
 #define ALCATEL_MULTICAST_PKT	0x01000000
 #define ALCATEL_BROADCAST_PKT	0x02000000
@@ -2557,7 +2557,7 @@ static void et131x_handle_recv_interrupt(struct et131x_adapter *adapter)
 	struct rx_ring *rx_ring = &adapter->rx_ring;
 
 	/* Process up to available RFD's */
-	while (count < NUM_PACKETS_HANDLED) {
+	while (count < MAX_PACKETS_HANDLED) {
 		if (list_empty(&rx_ring->recv_list)) {
 			WARN_ON(rx_ring->num_ready_recv != 0);
 			done = false;
@@ -2589,7 +2589,7 @@ static void et131x_handle_recv_interrupt(struct et131x_adapter *adapter)
 		count++;
 	}
 
-	if (count == NUM_PACKETS_HANDLED || !done) {
+	if (count == MAX_PACKETS_HANDLED || !done) {
 		rx_ring->unfinished_receives = true;
 		writel(PARM_TX_TIME_INT_DEF * NANO_IN_A_MICRO,
 		       &adapter->regs->global.watchdog_timer);
-- 
2.1.0
