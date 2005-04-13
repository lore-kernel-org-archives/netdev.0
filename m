From: Jean-Baptiste Note <jean-baptiste.note@wanadoo.fr>
Subject: Question on prism54 driver
Date: Wed, 13 Apr 2005 23:56:48 +0200
Message-ID: <87fyxu5oin.fsf@gxaafoot.homelinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <prism54-devel-bounces@prism54.org>
To: prism54-devel@prism54.org
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Sender: prism54-devel-bounces@prism54.org
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org


Dear list,

Going through the prism54 code for reuse in the softmac driver, i
stumbled accross inconsistencies in the queue management functions for
the mgmt rx queue and the data rx queue that i cannot understand.

Is there any reason that we have the following call in
islpci_mgt_receive (file islpci_mgt.c):

		/* Ensure the results of device DMA are visible to the CPU. */
		pci_dma_sync_single(priv->pdev, buf->pci_addr,
				    frag_len, PCI_DMA_FROMDEVICE);

but have nothing of the sort in islpci_eth_receive (file islpci_eth.c) ?

In the same spirit, the control block is also written by DMA by the
device, I guess ; so how comes we don't have such a syncing call in the
interrupt handler before accessing the control block's values (file
islpci_dev.c) ?

Am i missing something very obvious or very subtle ? -- should shared
memory be always sync'd before reading, or should we avoid it in cases
where we know it's not necessary, as an optimization ?

JB

-- 
Jean-Baptiste Note
+33 (0)6 83 03 42 38
jean-baptiste.note@wanadoo.fr
