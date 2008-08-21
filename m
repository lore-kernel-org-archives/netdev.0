From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/1] r8169: balance pci_map / pci_unmap pair
Date: Thu, 21 Aug 2008 14:57:11 -0700
Message-ID: <20080821145711.86bace2a.akpm@linux-foundation.org>
References: <20080821214734.GB22540@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi,
	alistair@devzero.co.uk, tjfontaine@atxconsulting.com,
	edward_hsu@realtek.com.tw, ivecera@redhat.com, stable@kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:38997 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756733AbYHUV7U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 17:59:20 -0400
In-Reply-To: <20080821214734.GB22540@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 21 Aug 2008 23:47:34 +0200
Francois Romieu <romieu@fr.zoreil.com> wrote:

> The leak hurts with swiotlb and jumbo frames (see
> http://bugzilla.kernel.org/show_bug.cgi?id=9468).
> 
> Heavily hinted by Ilpo J__rvinen <ilpo.jarvinen@helsinki.fi>.
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Tested-by: Alistair John Strachan <alistair@devzero.co.uk>
> Tested-by: Timothy J Fontaine <tjfontaine@atxconsulting.com>
> Cc: Edward Hsu <edward_hsu@realtek.com.tw>
> ---
>  drivers/net/r8169.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index a3e3895..0f6f974 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -2792,7 +2792,7 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
>  					pkt_size, PCI_DMA_FROMDEVICE);
>  				rtl8169_mark_to_asic(desc, tp->rx_buf_sz);
>  			} else {
> -				pci_unmap_single(pdev, addr, pkt_size,
> +				pci_unmap_single(pdev, addr, tp->rx_buf_sz,
>  						 PCI_DMA_FROMDEVICE);
>  				tp->Rx_skbuff[entry] = NULL;
>  			}

Also needed in 2.6.25.x and 2.6.26.x, yes?
