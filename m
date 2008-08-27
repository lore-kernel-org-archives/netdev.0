From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH resend 1/1] r8169: balance pci_map / pci_unmap pair
Date: Wed, 27 Aug 2008 05:18:27 -0400
Message-ID: <48B51BE3.6010606@garzik.org>
References: <20080826195606.GA31263@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Alistair John Strachan <alistair@devzero.co.uk>,
	Timothy J Fontaine <tjfontaine@atxconsulting.com>,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ivan Vecera <ivecera@redhat.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45237 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753769AbYH0JSx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 05:18:53 -0400
In-Reply-To: <20080826195606.GA31263@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rancois Romieu wrote:
> The leak hurts with swiotlb and jumbo frames.
>=20
> Fix http://bugzilla.kernel.org/show_bug.cgi?id=3D9468.
>=20
> Heavily hinted by Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>.
>=20
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Tested-by: Alistair John Strachan <alistair@devzero.co.uk>
> Tested-by: Timothy J Fontaine <tjfontaine@atxconsulting.com>
> Cc: Edward Hsu <edward_hsu@realtek.com.tw>
> ---
>  drivers/net/r8169.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index a3e3895..0f6f974 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -2792,7 +2792,7 @@ static int rtl8169_rx_interrupt(struct net_devi=
ce *dev,
>  					pkt_size, PCI_DMA_FROMDEVICE);
>  				rtl8169_mark_to_asic(desc, tp->rx_buf_sz);
>  			} else {
> -				pci_unmap_single(pdev, addr, pkt_size,
> +				pci_unmap_single(pdev, addr, tp->rx_buf_sz,
>  						 PCI_DMA_FROMDEVICE);

applied


