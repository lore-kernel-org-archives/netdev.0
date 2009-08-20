From: Walt Holman <walt@holmansrus.com>
Subject: Re: Strange network timeouts w/ 2.6.30.5
Date: Thu, 20 Aug 2009 17:21:23 -0500 (CDT)
Message-ID: <322550336.131250806883202.JavaMail.root@mail.holmansrus.com>
References: <m3skfmk39q.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932096AbZHTWV1@vger.kernel.org>
In-Reply-To: <m3skfmk39q.fsf@intrepid.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


----- "Krzysztof Halasa" <khc@pm.waw.pl> wrote:

> Walt Holman <walt@holmansrus.com> writes:
>=20
> > dmesg is attached. This box does have >2GB Ram (6GB total).  The
> dmesg
> > will show e100 init'd 3 times since the first is the stock
> modprobe,
> > 2nd was forced with use_io and the 3rd modprobe was after reverting
> > the patch.
>=20
> You most probably can't test without swiotlb (RAM has to be limited
> to
> 2 GB or so), can you? That would (dis)prove my theory. Alternatively
> (or
> better), a test on IOMMU-equipped system would do.

Would something like passing a mem=3Dxx cmdline on x86_64 be sufficient=
 to test this?

-Walt



>=20
> Since swiotlb is x86-only thing (though other 64-bit archs may have
> something similar), I think the correct work around is to enable the
> "for_device" handoff on !X86.
>=20
> Something like maybe:
>=20
> Signed-off-by: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>
>=20
> diff --git a/drivers/net/e100.c b/drivers/net/e100.c
> index 014dfb6..b610088 100644
> --- a/drivers/net/e100.c
> +++ b/drivers/net/e100.c
> @@ -1762,9 +1762,12 @@ static int e100_rx_indicate(struct nic *nic,
> struct rx *rx,
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
> Krzysztof Halasa
