From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: fix rtable leak in net/ipv4/route.c
Date: Wed, 20 May 2009 13:13:41 +0200
Message-ID: <4A13E5E5.4060007@cosmosbay.com>
References: <20090519162048.GB28034@hmsreliant.think-freely.org> <4A12FEDA.7040806@cosmosbay.com> <20090519192450.GF28034@hmsreliant.think-freely.org> <20090519.150517.62361946.davem@davemloft.net> <4A138CFE.5070901@cosmosbay.com> <4A139FC4.7030309@cosmosbay.com> <20090520100318.GA5789@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, nhorman@tuxdriver.com,
	lav@yar.ru, shemminger@linux-foundation.org, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:45844 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753738AbZETLN5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2009 07:13:57 -0400
In-Reply-To: <20090520100318.GA5789@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski a =E9crit :
> On Wed, May 20, 2009 at 08:14:28AM +0200, Eric Dumazet wrote:
>> +					for (aux =3D rt_hash_table[i].chain;;) {
>> +						if (aux =3D=3D rth) {
>> +							length +=3D ONE;
>> +							break;
>> +						}
>> +						if (compare_hash_inputs(&aux->fl, &rth->fl))
>> +							break;
>> +						aux =3D aux->u.dst.rt_next;
>> +					}
>=20
> Very "interesting" for() usage, but isn't it more readable like this?=
:
>=20
> 					aux =3D rt_hash_table[i].chain;
> 					while (aux !=3D rth) {
> 						if (compare_hash_inputs(&aux->fl, &rth->fl))
> 							break;
> 						aux =3D aux->u.dst.rt_next;
> 					}

well, this test is done two times, this is the difference...

>=20
> 					if (aux =3D=3D rth)
> 						length +=3D ONE;
>=20
> Jarek P.

I first wrote :

					for (aux =3D rt_hash_table[i].chain ; ; aux =3D aux->u.dst.rt_next=
) {
						if (aux =3D=3D rth) {
							length +=3D ONE;
							break;
						}
						if (compare_hash_inputs(&aux->fl, &rth->fl))
							break;
					}

but had to split the too long line, so ended in the form in the patch :=
)


Thank you


