From: David Acker <dacker@roinet.com>
Subject: Re: [PATCH] Fix e100 on systems that have cache incoherent DMA
Date: Tue, 01 Jul 2008 17:35:50 -0400
Message-ID: <486AA336.7010102@roinet.com>
References: <20071108181741.8648.61629.stgit@localhost.localdomain> <474DBDA6.50705@roinet.com> <474DBFCE.8010101@intel.com> <474DC0F3.8070604@garzik.org> <474DC68D.9020003@roinet.com> <485959DC.80902@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jeff@garzik.org>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	miltonm@bga.com, e1000-devel@lists.sourceforge.net,
	kexin.hao@windriver.com
To: =?ISO-8859-1?Q?Anders_Grafstr=F6m?= <grfstrm@users.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-72-92-88-10.phlapa.fios.verizon.net ([72.92.88.10]:40461
	"EHLO smtp.roinet.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752085AbYGAVfv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2008 17:35:51 -0400
In-Reply-To: <485959DC.80902@users.sourceforge.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anders Grafstr=F6m wrote:
>>>> David Acker wrote:
>>>>> What is the status of this patch?
>>>>
>>>> Jeff merged it in netdev-2.6#upstream so it is queued for 2.6.25.
>=20
> The e100 driver broke in 2.6.25 on the ixp4xx based platform I'm usin=
g.
> This patch seems to be the cause.
>=20
> It appears to work again with pci_dma_sync_single_for_device() restor=
ed.
> So I'm wondering if the patch below would be valid and correct?
>=20
> Anders
>=20
> diff --git a/drivers/net/e100.c b/drivers/net/e100.c
> index f3cba5e..1037b13 100644
> --- a/drivers/net/e100.c
> +++ b/drivers/net/e100.c
> @@ -1803,6 +1803,8 @@ static int e100_rx_alloc_skb(struct nic *nic,=20
> struct rx *rx)
>      if (rx->prev->skb) {
>          struct rfd *prev_rfd =3D (struct rfd *)rx->prev->skb->data;
>          put_unaligned_le32(rx->dma_addr, &prev_rfd->link);
> +        pci_dma_sync_single_for_device(nic->pdev, rx->prev->dma_addr=
,
> +            sizeof(struct rfd), PCI_DMA_TODEVICE);
>      }
>=20
>      return 0;
> --=20

Acked-by: David Acker <dacker@roinet.com>

I got a chance to test this patch on both a Compulab CM-X255 and a=20
Gateworks Avila GW2348-4.  It seems to work fine with little to no=20
performance hit.  I will give it some longer tests over this week.  If =
I=20
run into any problems I will report them here.  Thanks to Anders and=20
Kevin Hao who posted a similar patch.
-Ack

