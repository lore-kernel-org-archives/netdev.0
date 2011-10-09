From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] truesize lies
Date: Sun, 09 Oct 2011 23:55:20 +0200
Message-ID: <1318197320.21116.11.camel@edumazet-laptop>
References: <1318186948.5276.49.camel@edumazet-laptop>
	 <20111009.172739.2151675769111763947.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49030 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750861Ab1JIVz2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Oct 2011 17:55:28 -0400
Received: by wyg34 with SMTP id 34so5352068wyg.19
        for <netdev@vger.kernel.org>; Sun, 09 Oct 2011 14:55:27 -0700 (PDT)
In-Reply-To: <20111009.172739.2151675769111763947.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 09 octobre 2011 =C3=A0 17:27 -0400, David Miller a =C3=A9cr=
it :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sun, 09 Oct 2011 21:02:28 +0200
>=20
> > I guess most driver writers adjust truesize to please TCP stack and=
 get
> > nice performance numbers.
> >=20
> > skb->truesize =3D frame_len + sizeof(sk_buff);
> >=20
> > What should we do exactly ?
>=20
> We should pick a specification that accounts for all the metadata as =
well
> as unused data areas properly, and enforce this in netif_receive_skb(=
).
>=20
> That will get the inaccurate cases fixed real fast.
>=20
> We've had similar problems in the past and dealt with it in the same
> exact way.


Some drivers splits a page in two (or more) pieces, so we cant know wha=
t
was really reserved by a driver for paged skbs.

Only thing we could enforce at the moment is the proper accounting for
skb head :

WARN_ON(skb->truesize < (skb_end_pointer(skb) - skb->head) + sizeof(sk_=
buff) + skb->data_len);
