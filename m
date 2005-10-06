From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [KJ] [PATCH] starfire: free_irq() on error path of netdev_open()
Date: Fri, 7 Oct 2005 02:05:23 +0400
Message-ID: <20051006220523.GD2370@mipter.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============054015298608830031=="
Cc: netdev@vger.kernel.org, kernel-janitors@lists.osdl.org
Return-path: <kernel-janitors-bounces@lists.osdl.org>
To: Ion Badulescu <ionut@cs.columbia.edu>
List-Unsubscribe: <https://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/kernel-janitors>
List-Post: <mailto:kernel-janitors@lists.osdl.org>
List-Help: <mailto:kernel-janitors-request@lists.osdl.org?subject=help>
List-Subscribe: <https://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=subscribe>
Sender: kernel-janitors-bounces@lists.osdl.org
Errors-To: kernel-janitors-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

--===============054015298608830031==
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 drivers/net/starfire.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

--- ./drivers/net/starfire.c
+++ ./drivers/net/starfire.c
@@ -1091,8 +1091,10 @@ static int netdev_open(struct net_device
 		rx_ring_size = sizeof(struct starfire_rx_desc) * RX_RING_SIZE;
 		np->queue_mem_size = tx_done_q_size + rx_done_q_size + tx_ring_size + rx_ring_size;
 		np->queue_mem = pci_alloc_consistent(np->pci_dev, np->queue_mem_size, &np->queue_mem_dma);
-		if (np->queue_mem == 0)
+		if (np->queue_mem == 0) {
+			free_irq(dev->irq, dev);
 			return -ENOMEM;
+		}
 
 		np->tx_done_q     = np->queue_mem;
 		np->tx_done_q_dma = np->queue_mem_dma;


--===============054015298608830031==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

_______________________________________________
Kernel-janitors mailing list
Kernel-janitors@lists.osdl.org
https://lists.osdl.org/mailman/listinfo/kernel-janitors

--===============054015298608830031==--
