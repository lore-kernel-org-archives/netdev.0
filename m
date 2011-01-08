From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v2] net: ppp: use {get,put}_unaligned_be{16,32}
Date: Sat, 08 Jan 2011 11:33:14 +0100
Message-ID: <4D283D6A.4050502@gmail.com>
References: <1294357056-25889-1-git-send-email-xiaosuo@gmail.com>	 <20110107030145.GA8021@brick.ozlabs.ibm.com>	 <AANLkTim=1GCah0qp8HJK31LWXPb5vAZYp+d2BTQM+Q+B@mail.gmail.com>	 <20110107.171534.193718114.davem@davemloft.net>	 <4D2836BB.6000600@gmail.com> <1294482005.2709.90.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, xiaosuo@gmail.com,
	paulus@samba.org, harvey.harrison@gmail.com,
	linux-ppp@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:39249 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750949Ab1AHKdU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Jan 2011 05:33:20 -0500
In-Reply-To: <1294482005.2709.90.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Le samedi 08 janvier 2011 =C3=A0 11:04 +0100, Jarek Poplawski a =C3=A9=
crit :
>=20
>> Just for the record: I agree with Paul that current code is more rea=
dable.
>> This code still requires thinking about specific bytes and the patch=
 mixes
>> it only with word access.
>>
>> Jarek P.
>>
>>> @@ -395,16 +396,14 @@ mppe_compress(void *arg, unsigned char *ibuf,=
 unsigned char *obuf,
>>>  	 */
>>>  	obuf[0] =3D PPP_ADDRESS(ibuf);
>>>  	obuf[1] =3D PPP_CONTROL(ibuf);
>>> -	obuf[2] =3D PPP_COMP >> 8;	/* isize + MPPE_OVHD + 1 */
>>> -	obuf[3] =3D PPP_COMP;	/* isize + MPPE_OVHD + 2 */
>>> +	put_unaligned_be16(PPP_COMP, obuf + 2);
>>>  	obuf +=3D PPP_HDRLEN;
>=20
> Compilers are stupid not generating optimal code, so we should help t=
hem
> a bit.
>=20
> Yes, I agree this is ugly Jarek and makes reading of this code a bit
> more complex, but this is a move we cannot stop. Number of functions,
> macros, etc... is exploding and we must follow the trend ;)
>=20
> 41 c6 44 24 02 00       movb   $0x0,0x2(%r12)
> 41 c6 44 24 03 fd       movb   $0xfd,0x3(%r12)
>=20
> After patch :
>=20
> 66 41 c7 44 24 02 00 fd   movw   $0xfd00,0x2(%r12)

And that's why Paul wanted more justification, because readability
gain is questionable.

Jarek P.
