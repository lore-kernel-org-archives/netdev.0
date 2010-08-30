From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] gro: Is it ok to share a single napi from several devs ?
Date: Mon, 30 Aug 2010 08:57:21 -0700
Message-ID: <20100830085721.54c8c31b@nehalam>
References: <1283107162.2297.32.camel@edumazet-laptop>
	<20100830064231.GA7060@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59099 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754893Ab0H3P5Y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Aug 2010 11:57:24 -0400
In-Reply-To: <20100830064231.GA7060@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 30 Aug 2010 06:42:31 +0000
Jarek Poplawski <jarkao2@gmail.com> wrote:

> On 2010-08-29 20:39, Eric Dumazet wrote:
> > Le dimanche 29 ao=C3=BBt 2010 =C3  10:06 -0700, David Miller a =C3=A9=
crit :
> >> From: Jarek Poplawski <jarkao2@gmail.com>
> >> Date: Sun, 29 Aug 2010 11:59:51 +0200
> >>
> >>> Actually, when GRO compares napi->dev to skb->dev?
> >>
> >> Hmmm, I thought the code made a skb->dev comparison with the
> >> existing SKBs in the list when checking for same-flow matches.
> >>
> >> It doesn't, probably based upon the assumption that a NAPI
> >> instance maps to a unique device, the very topic we're
> >> discussing right now :-/
> >>
> >>
> >=20
> > It does the check, Stephen added it in the commit I mentioned to st=
art
> > this thread.
> >=20
> > With net-next-2.6 this now reads :
> >=20
>=20
> Since Stephen didn't seem to miss this too much it seems quite obviou=
s
> to me this check should be removed.

No. I just don't use that system much, breaking code for
sake of one comparison is ridiculous. If you need to do some
performance wanking, go figure out why just loading netfilter
drops forwarding performance by 20%.
