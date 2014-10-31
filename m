From: Kevin Hao <haokexin@gmail.com>
Subject: Re: [PATCH] net: gianfar: fix dma check map error when DMA_API_DEBUG
 is enabled
Date: Fri, 31 Oct 2014 11:09:40 +0800
Message-ID: <20141031030940.GA14783@pek-khao-d1.corp.ad.wrs.com>
References: <1414664727-21988-1-git-send-email-haokexin@gmail.com>
 <54526711.1080505@freescale.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="/04w6evG8XlLl3ft"
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:42314 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422693AbaJaDJs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 23:09:48 -0400
Received: by mail-pa0-f41.google.com with SMTP id rd3so6770151pab.14
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2014 20:09:47 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <54526711.1080505@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--/04w6evG8XlLl3ft
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Oct 30, 2014 at 06:28:01PM +0200, Claudiu Manoil wrote:
> On 10/30/2014 12:25 PM, Kevin Hao wrote:
>=20
> [...]
>=20
> >@@ -2406,6 +2416,25 @@ static int gfar_start_xmit(struct sk_buff *skb, s=
truct net_device *dev)
> >  	spin_unlock_irqrestore(&tx_queue->txlock, flags);
> >
> >  	return NETDEV_TX_OK;
> >+
> >+dma_map_err:
> >+	txbdp =3D next_txbd(txbdp_start, base, tx_queue->tx_ring_size);
> >+	if (do_tstamp)
> >+		txbdp =3D next_txbd(txbdp, base, tx_queue->tx_ring_size);
> >+	for (i =3D 0; i < nr_frags; i++) {
> >+		lstatus =3D txbdp->lstatus;
> >+		if (!(lstatus & BD_LFLAG(TXBD_READY)))
> >+			break;
> >+
> >+		txbdp->lstatus =3D lstatus & ~BD_LFLAG(TXBD_READY);
> >+		bufaddr =3D txbdp->bufPtr;
> >+		dma_unmap_page(priv->dev, bufaddr, txbdp->length,
> >+			       DMA_TO_DEVICE);
> >+		txbdp =3D next_txbd(txbdp, base, tx_queue->tx_ring_size);
> >+	}
> >+	gfar_wmb();
>=20
> Why use the wmb() memory barrier here?

Just want make sure that the update to the txbdp->lstatus is performed befo=
re
any possible update to the BD fields later. Maybe this seems a bit redundan=
t.
But this is not in hot path, so we may tolerate this overhead for more safe=
ty.

Thanks,
Kevin

--/04w6evG8XlLl3ft
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBAgAGBQJUUv10AAoJEJNY7TDerrFx4bAH/37y9LKVv+WDeJ6HDcoP2vls
6meCdpKlex5HfNxntG9UPYRvZoeNub3yCetmGDA3E//red7h5LujeOStJQ9TygLU
u9YtVoEA8FFFAaT36pq8/W+Ebfu4fZMHwh/IhS86aOTxdlsMu8xmU05MzfnX6uu4
iue8yCtzmjippR2WBt77sZOIFvfa2isnNxXoJZLNkWy+pEdaNi3+qV/QumjoY8kb
1Tm53QwV5N9cydry4+UPHcZJPE+TIwUlrc0WvqHSTFY7qXq+GMPuelvPBS6XXxN+
6D+Rxw9AXjvwOMPNNgBwe3Gq4Y9PIBGddav7X65n18B5ikYhEtZWZDHJcTuYfsY=
=Xk8/
-----END PGP SIGNATURE-----

--/04w6evG8XlLl3ft--
