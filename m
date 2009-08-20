From: David Miller <davem@davemloft.net>
Subject: Re: Strange network timeouts w/ 2.6.30.5
Date: Thu, 20 Aug 2009 12:28:50 -0700 (PDT)
Message-ID: <20090820.122850.37712606.davem@davemloft.net>
References: <985009134.71250769263099.JavaMail.root@mail.holmansrus.com>
	<m3skfmk39q.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: walt@holmansrus.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: khc@pm.waw.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36352
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755253AbZHTT2i convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Aug 2009 15:28:38 -0400
In-Reply-To: <m3skfmk39q.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krzysztof Halasa <khc@pm.waw.pl>
Date: Thu, 20 Aug 2009 15:45:21 +0200

> Something like maybe:
>=20
> Signed-off-by: Krzysztof Ha=B3asa <khc@pm.waw.pl>
>=20
> diff --git a/drivers/net/e100.c b/drivers/net/e100.c
> index 014dfb6..b610088 100644
> --- a/drivers/net/e100.c
> +++ b/drivers/net/e100.c
> @@ -1762,9 +1762,12 @@ static int e100_rx_indicate(struct nic *nic, s=
truct rx *rx,
> =20
>  			if (ioread8(&nic->csr->scb.status) & rus_no_res)
>  				nic->ru_running =3D RU_SUSPENDED;
> +#ifndef CONFIG_X86
> +		/* FIXME interferes with swiotlb. */
>  		pci_dma_sync_single_for_device(nic->pdev, rx->dma_addr,
>  					       sizeof(struct rfd),
>  					       PCI_DMA_BIDIRECTIONAL);
> +#endif
>  		return -ENODATA;
>  	}
> =20

I'm not willing to apply something like this.

swiotlb emulates what hardware does, so if it can go wrong with
swiotlb it can go wrong with hardware to.

=46igure out what the exact bug is.
