From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: RPS and forwarding
Date: Mon, 26 Apr 2010 09:25:16 +0200
Message-ID: <1272266716.2346.5.camel@edumazet-laptop>
References: <z2w65634d661004252144z1bf72880wdf7a0143b8490ddf@mail.gmail.com>
	 <20100426045316.GA21810@gondor.apana.org.au>
	 <r2n65634d661004252200x4e7a49f1h181cdd69b3e4ebc0@mail.gmail.com>
	 <20100425.232857.145290769.davem@davemloft.net>
	 <20100426063136.GA22401@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:37685 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754533Ab0DZHZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 03:25:21 -0400
Received: by bwz19 with SMTP id 19so181811bwz.21
        for <netdev@vger.kernel.org>; Mon, 26 Apr 2010 00:25:20 -0700 (PDT)
In-Reply-To: <20100426063136.GA22401@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 26 avril 2010 =C3=A0 14:31 +0800, Herbert Xu a =C3=A9crit :
> On Sun, Apr 25, 2010 at 11:28:57PM -0700, David Miller wrote:

>=20
> > It might be possible to somehow make the sock table get bypassed fo=
r
> > forwarded traffic, but I can't think of a cheap way to do that at
> > the moment.
>=20
> Yeah I thought about that too but as we need to go through the
> routing table before we know whether something is forwarded or
> not, it certainly seems non-trivial.
>=20
> Hmm, maybe if we used a routing cache keyed by rxhash we could
> make an appromixation? After all, we only need to make sure that
> no forwarded traffic is redirected, and not the reverse.  IOW,
> it's OK if we incorrectly classify some local traffic as forwarded.
>=20

RFS is already working like that, if RPS is not used in conjonction.

=46orwarded traffic will see a non tagged rfs flow entry, so this skb w=
ill
be processed by this cpu, not a remote one.

Currently, only an application can set a RFS flow entry.



