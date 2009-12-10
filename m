From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] gianfar: Fix stats support
Date: Thu, 10 Dec 2009 07:13:07 +0100
Message-ID: <4B209173.7030304@gmail.com>
References: <1260423764-21210-1-git-send-email-Sandeep.Kumar@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, avorontsov@ru.mvista.com,
	davem@davemloft.net
To: Sandeep Gopalpet <Sandeep.Kumar@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:43247 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932937AbZLJGNT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 01:13:19 -0500
In-Reply-To: <1260423764-21210-1-git-send-email-Sandeep.Kumar@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 10/12/2009 06:42, Sandeep Gopalpet a =E9crit :
> This patch updates the per rx/tx queue stats.
> To update the per rx queue stats a new structure has been
> introduced rx_q_stats.
> The per tx queue stats are updated via the netdev_queue
> structure itself.
>=20
> Note that we update only the tx_packtes, tx_bytes, rx_packets,
> rx_bytes and rx_dropped stats on a per queue basis.
>=20
> Signed-off-by: Sandeep Gopalpet <Sandeep.Kumar@freescale.com>

> +
> +	for (i =3D 0; i < priv->num_tx_queues; i++) {
> +		txq =3D netdev_get_tx_queue(dev, i);
> +		tx_bytes +=3D txq->tx_bytes;
> +		tx_packets +=3D txq->tx_packets;
> +	}
> +
> +	dev->stats.tx_bytes =3D tx_bytes;
> +	dev->stats.tx_packets =3D tx_packets;
> +
> +	return &dev->stats;

=46ine by me, but if this patch is for linux-2.6.33, you can use dev_tx=
q_stats_fold()
helper in your gfar_get_stats()

dev_txq_stats_fold(dev, &dev->stats);
return &dev->stats;

