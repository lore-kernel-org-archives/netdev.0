From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: Bug: mv643xxx fails with highmem
Date: Thu, 11 Dec 2014 20:25:07 +0000
Message-ID: <20141211202507.GS11285@n2100.arm.linux.org.uk>
References: <20141211194920.GR11285@n2100.arm.linux.org.uk>
 <20141211.151055.817876561546126576.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ezequiel.garcia@free-electrons.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Nimrod Andy <B38611@freescale.com>,
	Fabio Estevam <fabio.estevam@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:52367 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758237AbaLKUZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 15:25:19 -0500
Content-Disposition: inline
In-Reply-To: <20141211.151055.817876561546126576.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 11, 2014 at 03:10:55PM -0500, David Miller wrote:
> From: Russell King - ARM Linux <linux@arm.linux.org.uk>
> Date: Thu, 11 Dec 2014 19:49:20 +0000
> 
> > Commit 69ad0dd7af22 removed skb_frag_dma_map() in favour of mapping
> > all fragments with dma_map_single().  This fails when the driver is
> > used in an environment with highmem.
> 
> This change looks really buggy to me.
> 
> Unfortunately, all the changes he subsequently makes for software TSO
> support depend upon this :-/
> 
> The change is definitely wrong.

Thanks for confirming where the bug is.

Would other drivers need fixing for this as well?  Eg, fec_main.c
does the following, and this driver is used on iMX6 which can also have
highmem:

static int
fec_enet_txq_submit_frag_skb(struct fec_enet_priv_tx_q *txq,
                             struct sk_buff *skb,
                             struct net_device *ndev)
{
                bufaddr = page_address(this_frag->page.p) + this_frag->page_offset;
...
                addr = dma_map_single(&fep->pdev->dev, bufaddr, frag_len,
                                      DMA_TO_DEVICE);

-- 
FTTC broadband for 0.8mile line: currently at 9.5Mbps down 400kbps up
according to speedtest.net.
