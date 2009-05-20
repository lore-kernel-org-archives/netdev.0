From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] net: fix rtable leak in net/ipv4/route.c
Date: Wed, 20 May 2009 11:37:40 +0000
Message-ID: <20090520113740.GA6546@ff.dom.local>
References: <20090519162048.GB28034@hmsreliant.think-freely.org> <4A12FEDA.7040806@cosmosbay.com> <20090519192450.GF28034@hmsreliant.think-freely.org> <20090519.150517.62361946.davem@davemloft.net> <4A138CFE.5070901@cosmosbay.com> <4A139FC4.7030309@cosmosbay.com> <20090520100318.GA5789@ff.dom.local> <4A13E5E5.4060007@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, nhorman@tuxdriver.com,
	lav@yar.ru, shemminger@linux-foundation.org, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.182]:52918 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753055AbZETLhu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2009 07:37:50 -0400
Received: by wa-out-1112.google.com with SMTP id j5so85941wah.21
        for <netdev@vger.kernel.org>; Wed, 20 May 2009 04:37:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A13E5E5.4060007@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 20, 2009 at 01:13:41PM +0200, Eric Dumazet wrote:
> Jarek Poplawski a =E9crit :
> > On Wed, May 20, 2009 at 08:14:28AM +0200, Eric Dumazet wrote:
> >> +					for (aux =3D rt_hash_table[i].chain;;) {
> >> +						if (aux =3D=3D rth) {
> >> +							length +=3D ONE;
> >> +							break;
> >> +						}
> >> +						if (compare_hash_inputs(&aux->fl, &rth->fl))
> >> +							break;
> >> +						aux =3D aux->u.dst.rt_next;
> >> +					}
> >=20
> > Very "interesting" for() usage, but isn't it more readable like thi=
s?:
> >=20
> > 					aux =3D rt_hash_table[i].chain;
> > 					while (aux !=3D rth) {
> > 						if (compare_hash_inputs(&aux->fl, &rth->fl))
> > 							break;
> > 						aux =3D aux->u.dst.rt_next;
> > 					}
>=20
> well, this test is done two times, this is the difference...

I know, but I guess this is used quite often. And probably it's not
very hard optimization for a compiler (while - else). As a matter of
fact even this would confuse me less here:
					aux =3D rt_hash_table[i].chain;
					for (;;) {

But of course, it's a matter of taste, so no big deal.

Jarek P.
