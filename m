From: Aviv Greenberg <avivgnet@gmail.com>
Subject: Re: Strange network timeouts w/ 2.6.30.5
Date: Sun, 23 Aug 2009 22:18:08 +0300
Message-ID: <20090823191808.GA29972@linux-gec2.site>
References: <985009134.71250769263099.JavaMail.root@mail.holmansrus.com> <m3skfmk39q.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Walt Holman <walt@holmansrus.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933890AbZHWTSQ@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m3skfmk39q.fsf@intrepid.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 20, 2009 at 03:45:21PM +0200, Krzysztof Halasa wrote:
=20
> Signed-off-by: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>
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
> --=20

Why do you use PCI_DMA_BIDIRECTIONAL? From what i get, the device write=
s and the
cpu reads - so the direction should be PCI_DMA_FROMDEVICE. Maybe just m=
aybe the=20
bi-directionality bites you in the swiotlb case.

> Krzysztof Halasa
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
