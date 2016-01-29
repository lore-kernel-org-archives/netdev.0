From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH net 3/6] net: mvneta: Remove unused code
Date: Fri, 29 Jan 2016 17:26:04 +0100
Message-ID: <1454084767-24715-4-git-send-email-gregory.clement@free-electrons.com>
References: <1454084767-24715-1-git-send-email-gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Lior Amsalem <alior@marvell.com>, Andrew Lunn <andrew@lunn.ch>,
 Russell King - ARM Linux <linux@arm.linux.org.uk>,
 Jason Cooper <jason@lakedaemon.net>, Nadav Haklai <nadavh@marvell.com>,
 Gregory CLEMENT <gregory.clement@free-electrons.com>,
 Marcin Wojtas <mw@semihalf.com>, Willy Tarreau <w@1wt.eu>,
 linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org,
 netdev@vger.kernel.org,
 Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1454084767-24715-1-git-send-email-gregory.clement@free-electrons.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Since the commit 2dcf75e2793c ("net: mvneta: Associate RX queues with
each CPU") all the percpu irq are used and unmask at initialization, so
there is no point to unmask them first.

Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 3d6e3137f305..861b7e0d7d5f 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -3009,14 +3009,6 @@ static int mvneta_open(struct net_device *dev)
 		goto err_cleanup_txqs;
 	}
 
-	/* Even though the documentation says that request_percpu_irq
-	 * doesn't enable the interrupts automatically, it actually
-	 * does so on the local CPU.
-	 *
-	 * Make sure it's disabled.
-	 */
-	mvneta_percpu_disable(pp);
-
 	/* Enable per-CPU interrupt on all the CPU to handle our RX
 	 * queue interrupts
 	 */
-- 
2.5.0
