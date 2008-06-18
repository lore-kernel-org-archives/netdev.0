From: =?ISO-8859-1?Q?Anders_Grafstr=F6m?= <grfstrm@users.sourceforge.net>
Subject: Re: [PATCH] Fix e100 on systems that have cache
	incoherent DMA
Date: Wed, 18 Jun 2008 20:54:20 +0200
Message-ID: <485959DC.80902@users.sourceforge.net>
References: <20071108181741.8648.61629.stgit@localhost.localdomain>
	<474DBDA6.50705@roinet.com> <474DBFCE.8010101@intel.com>
	<474DC0F3.8070604@garzik.org> <474DC68D.9020003@roinet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	Jeff Garzik <jeff@garzik.org>, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com, miltonm@bga.com,
	akpm@linux-foundation.org
To: David Acker <dacker@roinet.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <474DC68D.9020003@roinet.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

>>> David Acker wrote:
>>>> What is the status of this patch?
>>>
>>> Jeff merged it in netdev-2.6#upstream so it is queued for 2.6.25.

The e100 driver broke in 2.6.25 on the ixp4xx based platform I'm using.
This patch seems to be the cause.

It appears to work again with pci_dma_sync_single_for_device() restored.
So I'm wondering if the patch below would be valid and correct?

Anders

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index f3cba5e..1037b13 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -1803,6 +1803,8 @@ static int e100_rx_alloc_skb(struct nic *nic, struct rx *rx)
  	if (rx->prev->skb) {
  		struct rfd *prev_rfd = (struct rfd *)rx->prev->skb->data;
  		put_unaligned_le32(rx->dma_addr, &prev_rfd->link);
+		pci_dma_sync_single_for_device(nic->pdev, rx->prev->dma_addr,
+			sizeof(struct rfd), PCI_DMA_TODEVICE);
  	}

  	return 0;

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
