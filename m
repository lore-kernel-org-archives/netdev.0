From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2 46/46] net: mark drivers that drop packets from rx queue head under memory pressure
Date: Mon, 11 Jul 2011 07:40:22 +0200
Message-ID: <20110711054022.GA5981@electric-eye.fr.zoreil.com>
References: <cover.1310339688.git.mirq-linux@rere.qmqm.pl> <c84a04a957128ae664f4a80da23fad4b9f71a85f.1310339689.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:46486 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756510Ab1GKFyz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 01:54:55 -0400
Content-Disposition: inline
In-Reply-To: <c84a04a957128ae664f4a80da23fad4b9f71a85f.1310339689.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl> :
[...]
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index e2c2884..ce4bdaf 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -4999,6 +4999,9 @@ static struct sk_buff *rtl8169_try_rx_copy(void=
 *data,
>  	struct sk_buff *skb;
>  	struct device *d =3D &tp->pci_dev->dev;
> =20
> +#warning drops packets from rx queue head on memory pressure
> +#warning (like dev_skb_finish_rx_dma_refill() users)
> +
>  	data =3D rtl8169_align(data);
>  	dma_sync_single_for_cpu(d, addr, pkt_size, DMA_FROM_DEVICE);
>  	prefetch(data);

The commit messages explain why the driver works this way. I'd rather a=
void the
noise and - especially - the dubious patches it may generate.

--=20
Ueimor
