From: Joao Martins <joao.martins@neclab.eu>
Subject: [RFC PATCH 07/13] xen-netback: add persistent tree
	counters to debugfs
Date: Tue, 12 May 2015 19:18:31 +0200
Message-ID: <1431451117-70051-8-git-send-email-joao.martins@neclab.eu>
References: <1431451117-70051-1-git-send-email-joao.martins@neclab.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, ian.campbell@citrix.com,
	Joao Martins <joao.martins@neclab.eu>, david.vrabel@citrix.com,
	boris.ostrovsky@oracle.com
To: <xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1431451117-70051-1-git-send-email-joao.martins@neclab.eu>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

Prints the total/max number of persistent grants and how many of
them are in use.

Signed-off-by: Joao Martins <joao.martins@neclab.eu>
---
 drivers/net/xen-netback/xenbus.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index 766f7e5..1e6f27a 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -121,6 +121,17 @@ static int xenvif_read_io_ring(struct seq_file *m, void *v)
 		   skb_queue_len(&queue->rx_queue),
 		   netif_tx_queue_stopped(dev_queue) ? "stopped" : "running");
 
+	if (queue->vif->persistent_grants) {
+		seq_printf(m, "\nRx persistent_gnts: in_use %d max %d gnts %d\n",
+			   atomic_read(&queue->rx_gnts_tree.gnt_in_use),
+			   queue->rx_gnts_tree.gnt_max,
+			   queue->rx_gnts_tree.gnt_c);
+		seq_printf(m, "\nTx persistent_gnts: in_use %d max %d gnts %d\n",
+			   atomic_read(&queue->tx_gnts_tree.gnt_in_use),
+			   queue->tx_gnts_tree.gnt_max,
+			   queue->tx_gnts_tree.gnt_c);
+	}
+
 	return 0;
 }
 
-- 
2.1.3
