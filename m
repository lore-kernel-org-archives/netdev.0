From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] net: more accurate skb truesize
Date: Thu, 13 Oct 2011 17:32:44 +0100
Message-ID: <1318523564.2745.32.camel@bwh-desktop>
References: <1318519581.2393.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1318521901.2745.18.camel@bwh-desktop>
	 <1318523090.2393.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:23732 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751086Ab1JMQcq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 12:32:46 -0400
In-Reply-To: <1318523090.2393.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-10-13 at 18:24 +0200, Eric Dumazet wrote:
> Le jeudi 13 octobre 2011 =C3=A0 17:05 +0100, Ben Hutchings a =C3=A9cr=
it :
[...]
> > If that's not important, and we just want to be sure that the alloc=
ation
> > occupies at least a whole cache line, then it should be:
> > 	size =3D SKB_DATA_ALIGN(size + sizeof(struct skb_shared_info));
> >=20
> > But I don't think it makes sense to use SKB_DATA_ALIGN(sizeof(struc=
t
> > skb_shared_info)).
>=20
> If you take a closer look, you'll see that my patch addresses your
> concerns, but at minimal cpu cost.
>=20
> kmalloc(size + SKB_DATA_ALIGN(sizeof(struct skb_shared_info)))
>=20
> will give same result than :
>=20
> kmalloc(SKB_DATA_ALIGN(size) + SKB_DATA_ALIGN(sizeof(struct
> skb_shared_info)))
>=20
> But my version is a bit faster (a single add of a compiler known
> constant)

=46air enough, but please add a comment explaining this.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
