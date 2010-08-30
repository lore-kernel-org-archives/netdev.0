From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] gro: Is it ok to share a single napi from several devs ?
Date: Mon, 30 Aug 2010 20:36:21 +0200
Message-ID: <20100830183620.GA3079@del.dom.local>
References: <1283107162.2297.32.camel@edumazet-laptop>
 <20100830064231.GA7060@ff.dom.local>
 <20100830085721.54c8c31b@nehalam>
 <20100830.095012.233695092.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, eric.dumazet@gmail.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:42260 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751733Ab0H3SiZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Aug 2010 14:38:25 -0400
Received: by fxm13 with SMTP id 13so3480344fxm.19
        for <netdev@vger.kernel.org>; Mon, 30 Aug 2010 11:38:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100830.095012.233695092.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 30, 2010 at 09:50:12AM -0700, David Miller wrote:
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Mon, 30 Aug 2010 08:57:21 -0700
>=20
> > On Mon, 30 Aug 2010 06:42:31 +0000
> > Jarek Poplawski <jarkao2@gmail.com> wrote:
> >=20
> >> On 2010-08-29 20:39, Eric Dumazet wrote:
> >> > Le dimanche 29 ao=C3=BBt 2010 =C3  10:06 -0700, David Miller a =C3=
=A9crit :
> >> >> From: Jarek Poplawski <jarkao2@gmail.com>
> >> >> Date: Sun, 29 Aug 2010 11:59:51 +0200
> >> >>
> >> >>> Actually, when GRO compares napi->dev to skb->dev?
> >> >>
> >> >> Hmmm, I thought the code made a skb->dev comparison with the
> >> >> existing SKBs in the list when checking for same-flow matches.
> >> >>
> >> >> It doesn't, probably based upon the assumption that a NAPI
> >> >> instance maps to a unique device, the very topic we're
> >> >> discussing right now :-/
> >> >>
> >> >>
> >> >=20
> >> > It does the check, Stephen added it in the commit I mentioned to=
 start
> >> > this thread.
> >> >=20
> >> > With net-next-2.6 this now reads :
> >> >=20
> >>=20
> >> Since Stephen didn't seem to miss this too much it seems quite obv=
ious
> >> to me this check should be removed.
> >=20
> > No. I just don't use that system much, breaking code for
> > sake of one comparison is ridiculous.
>=20
> It's not working to begin with.

IMHO it should work yet. On the other hand, after removing this test
GRO should still work OK for these NICs in most cases, so it should be
treated as an optimization only. And it seems very unusual to keep such
optimizations at this level for such rare cases.

> I agree with Jarek that the check should be removed.  And GRO is one
> of those places that, precisely, even one memory reference removal
> can improve performance dramatically.

Hmm... I proposed removal when Stephen didn't defend it. Since he
seems to change his line, I'd prefer to be convinced I'm wrong,
preferably with some use/test case; most preferably from some
desperated user...

> Herbert spent a lot of time doing micro-optimizations to make GRO
> better and better, and the smallest things can turn out to make a hug=
e
> difference there.

Anyway, after the last Eric's optimization, it's almost invisible...

Jarek P.
