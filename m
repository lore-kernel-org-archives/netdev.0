From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Fix e100 on systems that have cache
	incoherent DMA
Date: Tue, 1 Jul 2008 01:26:31 -0700
Message-ID: <20080701012631.c3d1d262.akpm@linux-foundation.org>
References: <20071108181741.8648.61629.stgit@localhost.localdomain>
	<474DBDA6.50705@roinet.com> <474DBFCE.8010101@intel.com>
	<474DC0F3.8070604@garzik.org> <474DC68D.9020003@roinet.com>
	<485959DC.80902@users.sourceforge.net>
	<48595F16.5000905@roinet.com>
	<485A5349.6070601@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	Jeff Garzik <jeff@garzik.org>, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com, miltonm@bga.com,
	David Acker <dacker@roinet.com>
To: Anders =?ISO-8859-1?Q?Grafstr=F6m?= <grfstrm@users.sourceforge.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <485A5349.6070601@users.sourceforge.net>
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

On Thu, 19 Jun 2008 14:38:33 +0200 Anders Grafstr__m <grfstrm@users.sourceforge.net> wrote:

> David Acker wrote:
> > May I ask what actual board you are using and how the e100 is connected 
> > to it?  I plan to test with miniPCI based e100 cards.  Also, can you say 
> > more about it being broke?  Does it crash immediately, fail to move any 
> > data, move some data and stop, etc. ?
> 
> It's a custom board based on the IXDP425 reference design.
> IXP420 with 82551ER integrated on the same board.
> Both RX and TX appears to stop shortly after the driver has been initialized.
> It never recovers after the "exec cuc_dump_reset failed" messages start to show.

So..  where are we with this?  e100 is a pretty popular device and
having it obscurely busted on kooky architectures is likely to be
unpopular.

Did this:

> --- a/drivers/net/e100.c
> +++ b/drivers/net/e100.c
> @@ -1803,6 +1803,8 @@ static int e100_rx_alloc_skb(struct nic *nic, struct rx *rx)
>   	if (rx->prev->skb) {
>   		struct rfd *prev_rfd = (struct rfd *)rx->prev->skb->data;
>   		put_unaligned_le32(rx->dma_addr, &prev_rfd->link);
> +		pci_dma_sync_single_for_device(nic->pdev, rx->prev->dma_addr,
> +			sizeof(struct rfd), PCI_DMA_TODEVICE);
>   	}
> 
>   	return 0;

actually fix it?

If so, it's probably better than nothing.

Thanks.

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
