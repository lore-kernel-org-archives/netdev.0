From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Mon, 17 Jan 2011 18:58:38 +0000
Message-ID: <1295290718.6264.19.camel@bwh-desktop>
References: <1294919372-1904-1-git-send-email-ratbert.chuang@gmail.com>
	 <1295256060-2091-1-git-send-email-ratbert.chuang@gmail.com>
	 <1295285354.3335.10.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Po-Yu Chuang <ratbert.chuang@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ratbert@faraday-tech.com,
	joe@perches.com, dilinger@queued.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:6884 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752055Ab1AQS6m convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jan 2011 13:58:42 -0500
In-Reply-To: <1295285354.3335.10.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-01-17 at 18:29 +0100, Eric Dumazet wrote:
> Le lundi 17 janvier 2011 =C3=A0 17:21 +0800, Po-Yu Chuang a =C3=A9cri=
t :
>=20
>=20
> > +static int ftmac100_rx_packet(struct ftmac100 *priv, int *processe=
d)
> > +{
> > +	struct net_device *netdev =3D priv->netdev;
> > +	struct ftmac100_rxdes *rxdes;
> > +	struct sk_buff *skb;
> > +	int length;
> > +	int copied =3D 0;
> > +	int done =3D 0;
> > +
> > +	rxdes =3D ftmac100_rx_locate_first_segment(priv);
> > +	if (!rxdes)
> > +		return 0;
> > +
> > +	length =3D ftmac100_rxdes_frame_length(rxdes);
> > +
> > +	netdev->stats.rx_packets++;
> > +	netdev->stats.rx_bytes +=3D length;
> > +
> > +	if (unlikely(ftmac100_rx_packet_error(priv, rxdes))) {
> > +		ftmac100_rx_drop_packet(priv);
> > +		return 1;
> > +	}
> > +
> > +	/* start processing */
> > +	skb =3D netdev_alloc_skb_ip_align(netdev, length);
> > +	if (unlikely(!skb)) {
> > +		if (net_ratelimit())
> > +			netdev_err(netdev, "rx skb alloc failed\n");
> > +
> > +		ftmac100_rx_drop_packet(priv);
> > +		return 1;
> > +	}
> > +
>=20
> Please dont increase rx_packets/rx_bytes before the
> netdev_alloc_skb_ip_align().
>=20
> In case of mem allocation failure, it would be better not pretending =
we
> handled a packet.
>
> drivers/net/r8169.c for example does the rx_packets/rx_bytes only if
> packet is delivered to upper stack.

That's news to me.  I specifically advised Po-Yu Chuang to increment
these earlier because my understanding is that all packets/bytes should
be counted.  And drivers which use hardware MAC stats will generally do
that, so I really don't think it makes sense to make other drivers
different deliberately.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

