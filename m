From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] atm: use SKB_TRUESIZE() in
 atm_guess_pdu2truesize()
Date: Tue, 22 Nov 2011 21:33:54 +0100
Message-ID: <1321994034.19663.9.camel@edumazet-laptop>
References: <1321941094.27077.14.camel@edumazet-laptop>
	 <20111122152207.114bcd68@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:38166 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755352Ab1KVUeA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 15:34:00 -0500
Received: by bke11 with SMTP id 11so697734bke.19
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2011 12:33:58 -0800 (PST)
In-Reply-To: <20111122152207.114bcd68@thirdoffive.cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 22 novembre 2011 =C3=A0 15:22 -0500, chas williams - CONTRACTO=
R a
=C3=A9crit :
> it doesnt seem like a good idea to create a wrapper for a one to one
> call.  perhaps this whole bit of nonsense should be removed.  the
> iphase driver should be returning skb->truesize like everyone. =20
>=20
> if atm_alloc_charge() just uses SKB_TRUESIZE() then we konw that gues=
s
> will be the same as skb->truesize and atm_alloc_charge() can be
> simplified by removing atomic_add(skb->truesize - guess, which will b=
e
> 0 in all cases.
>=20

Please note I didnt create a wrapper, only correct existing one :)

=46eel free to send a (tested) patch, but be warned that following code=
 is
not correct :

int size =3D something;

struct sk_buff *skb =3D skb_alloc(size);

ASSERT(skb->truesize =3D=3D SKB_TRUESIZE(size));

(It might be true with SLOB only)
