From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH][net-next] gianfar: Fix reported number of sent bytes to BQL
Date: Tue, 03 Sep 2013 20:18:12 +0100
Message-ID: <1943289.AeBmeBuHV2@lenovo>
References: <1367251193.8964.326.camel@edumazet-glaptop> <1377864075-19491-1-git-send-email-claudiu.manoil@freescale.com> <CAGVrzcaHLa1kT2wZc993cZFX2geQ4JgOO-u6JcWHFKcn-OZhZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:65095 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760684Ab3ICTSQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 15:18:16 -0400
Received: by mail-ee0-f52.google.com with SMTP id c41so3179155eek.25
        for <netdev@vger.kernel.org>; Tue, 03 Sep 2013 12:18:15 -0700 (PDT)
In-Reply-To: <CAGVrzcaHLa1kT2wZc993cZFX2geQ4JgOO-u6JcWHFKcn-OZhZw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 3 septembre 2013 19:59:42 Florian Fainelli a =E9crit :
> Hello Claudiu,
>=20
> 2013/8/30 Claudiu Manoil <claudiu.manoil@freescale.com>:
> > Fix the amount of sent bytes reported to BQL by reporting the
> > number of bytes on wire in the xmit routine, and recording that
> > value for each skb in order to be correctly confirmed on Tx
> > confirmation cleanup.
> >=20
> > Reporting skb->len to BQL just before exiting xmit is not correct
> > due to possible insertions of TOE block and alignment bytes in the
> > skb->data, which are being stripped off by the controller before
> > transmission on wire.  This led to mismatch of (incorrectly)
> > reported bytes to BQL b/w xmit and Tx confirmation, resulting in
> > Tx timeout firing, for the h/w tx timestamping acceleration case.
> >=20
> > There's no easy way to obtain the number of bytes on wire in the Tx
> > confirmation routine, so skb->cb is used to convey that information
> > from xmit to Tx confirmation, for now (as proposed by Eric). Revive=
d
> > the currently unused GFAR_CB() construct for that purpose.
>=20
> I do not see much difference between what this patch does and what th=
e
> current net-next drivers does. If you need to correctly account for
> this, it seems to me like you should move the stats/bytes_sent
> computation below this line:
>=20
>        if (unlikely(do_tstamp)) {
>                 skb_push(skb, GMAC_TXPAL_LEN);
>                 memset(skb->data, 0, GMAC_TXPAL_LEN);
>         }
>=20
> to account for the SKB length update?

Just realized that this is precisely what your patch is fixing, sorry f=
or the=20
noise.
--=20
=46lorian
