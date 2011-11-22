From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH net-next] atm: use SKB_TRUESIZE() in
 atm_guess_pdu2truesize()
Date: Tue, 22 Nov 2011 17:42:05 -0500
Message-ID: <20111122174205.6ef2021d@thirdoffive.cmf.nrl.navy.mil>
References: <1321941094.27077.14.camel@edumazet-laptop>
	<20111122152207.114bcd68@thirdoffive.cmf.nrl.navy.mil>
	<1321994034.19663.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:52206 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752565Ab1KVWnH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 17:43:07 -0500
In-Reply-To: <1321994034.19663.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 Nov 2011 21:33:54 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le mardi 22 novembre 2011 =C3=A0 15:22 -0500, chas williams - CONTRAC=
TOR a
> =C3=A9crit :
> > it doesnt seem like a good idea to create a wrapper for a one to on=
e
> > call.  perhaps this whole bit of nonsense should be removed.  the
> > iphase driver should be returning skb->truesize like everyone. =20
> >=20
> > if atm_alloc_charge() just uses SKB_TRUESIZE() then we konw that gu=
ess
> > will be the same as skb->truesize and atm_alloc_charge() can be
> > simplified by removing atomic_add(skb->truesize - guess, which will=
 be
> > 0 in all cases.
> >=20
>=20
> Please note I didnt create a wrapper, only correct existing one :)
>=20
> Feel free to send a (tested) patch, but be warned that following code=
 is
> not correct :
>=20
> int size =3D something;
>=20
> struct sk_buff *skb =3D skb_alloc(size);
>=20
> ASSERT(skb->truesize =3D=3D SKB_TRUESIZE(size));
>=20
> (It might be true with SLOB only)

perhaps it is best to say that you discovered an inadvertent wrapper.

given skb->truesize !=3D SKB_TRUESIZE() for all cases, it is certainly
wrong in the iphase driver to return the guessed value.  it should be
returning skb->truesize.  i will send along a patch shortly to just get
rid of this function.
