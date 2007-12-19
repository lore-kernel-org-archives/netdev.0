From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH net-2.6.25 1/3] Uninline the __inet_hash function
Date: Wed, 19 Dec 2007 18:15:20 +0100
Message-ID: <476951A8.4040200@cosmosbay.com>
References: <4768F77E.5090201@openvz.org> <47690CD1.9060502@cosmosbay.com> <47691B0B.2060508@openvz.org> <47694231.2070406@cosmosbay.com> <47694F96.6030604@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:48574 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752078AbXLSRPb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2007 12:15:31 -0500
In-Reply-To: <47694F96.6030604@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov a =E9crit :
> Eric Dumazet wrote:
>> Pavel Emelyanov a =E9crit :
>>> Eric Dumazet wrote:
>>>> If you un-inline this (good idea), I am not sure we still need lis=
ten_possible=20
>>>> argument.
>>>>
>>>> It was usefull only to help compiler to zap dead code (since it wa=
s known at=20
>>>> compile time), now it only adds some extra test and argument passi=
ng.
>>> Hm... I've tried to address this issue and got worse result - minus
>>> 600 bytes (vs minus 725). So, what would be more preferable - get a=
=20
>>> smaller code with one extra 'if' or get a bit larger code without i=
t?
>>>
>> Strange... What I meant is always assume listen_possible is true.
>=20
> That's not truth, if I get you right. The __inet_hash() is called
> with 0, from all the places except for the inet_hash() one.

OK, but on cases with 0, sk->sk_state is !=3D TCP_LISTEN, unless I am m=
istaken.


>=20
>> The if (sk->sk_state =3D=3D TCP_LISTEN) will finally see the truth.
>>
>> I did a test here on x86 gcc-4.2.2 and saved 32 bytes.
>>
>>
>>
>=20
> Thanks,
> Pavel
>=20
>=20

