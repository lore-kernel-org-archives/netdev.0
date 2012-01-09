From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH] gianfar: Fix invalid TX frames returned on error queue
 when time stamping.
Date: Mon, 09 Jan 2012 08:43:58 +0100
Message-ID: <1326095038.2627.4.camel@edumazet-laptop>
References: <1325775021-23049-1-git-send-email-manfred.rudigier@omicron.at>
	 <20120105.132637.2130515220408371607.davem@davemloft.net>
	 <95DC1AA8EC908B48939B72CF375AA5E3013A99124D@alice.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"afleming@freescale.com" <afleming@freescale.com>,
	"avorontsov@mvista.com" <avorontsov@mvista.com>
To: Manfred Rudigier <manfred.rudigier@omicron.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:43530 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755438Ab2AIHoD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2012 02:44:03 -0500
Received: by wgbdt14 with SMTP id dt14so1201965wgb.1
        for <netdev@vger.kernel.org>; Sun, 08 Jan 2012 23:44:01 -0800 (PST)
In-Reply-To: <95DC1AA8EC908B48939B72CF375AA5E3013A99124D@alice.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 09 janvier 2012 =C3=A0 08:16 +0100, Manfred Rudigier a =C3=A9c=
rit :
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, January 05, 2012 19:27
>=20
> >From: Manfred Rudigier <manfred.rudigier@omicron.at>
> >Date: Thu, 5 Jan 2012 15:50:21 +0100
> >
> >> +
> >> +		/* Keep sock if we must return a time stamp on the err queue */
> >> +		skb_new->sk =3D skb->sk;
> >
> >When I see something like this without any kind of reference countin=
g or
> >similar, I am gravely concerned.
>=20
> The skb_tstamp_tx function called during gfar_clean_tx_ring requires
> the skb->sk pointer to be set. Otherwise no time stamp can be queued
> on the socket error queue.=20
> What would be the correct way for doing this?

I really wonder how your code was possibly working...

A correct steal sequence maybe=20

	skb_new->sk =3D skb->sk;
	skb->sk =3D NULL;
	kfree_skb(skb);

Or else, kfree_skb() releases sk reference and eventually socket is
freed before skb_tstamp_tx()
