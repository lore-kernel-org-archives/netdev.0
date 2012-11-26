From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH] net: ipmr: limit MRT_TABLE identifiers
Date: Mon, 26 Nov 2012 09:34:39 +0800
Message-ID: <50B2C72F.9000100@asianux.com>
References: <50AC9CF6.2020501@asianux.com> <1353872669.30446.863.camel@edumazet-glaptop> <50B2C470.5090802@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:64082 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753411Ab2KZBdq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Nov 2012 20:33:46 -0500
In-Reply-To: <50B2C470.5090802@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B411=E6=9C=8826=E6=97=A5 09:22, Chen Gang =E5=86=99=
=E9=81=93:
> =E4=BA=8E 2012=E5=B9=B411=E6=9C=8826=E6=97=A5 03:44, Eric Dumazet =E5=
=86=99=E9=81=93:
>> From: Eric Dumazet <edumazet@google.com>
>>
>> Name of pimreg devices are built from following format :
>>
>> char name[IFNAMSIZ]; // IFNAMSIZ =3D=3D 16
>>
>> sprintf(name, "pimreg%u", mrt->id);
>>
>> We must therefore limit mrt->id to 9 decimal digits
>> or risk a buffer overflow and a crash.
>>
>> Restrict table identifiers in [0 ... 999999999] interval.
>>

    if "pimre%u" (or another format), will not hurt the functional feat=
ures, I suggest to use it
      since, we need try our best to not touch the OS API.=20
      ("pimreg%u" seems an internal format, not OS API Level)

>=20
>   if we have to stick to "pimreg%u" (or will hurt the functional feat=
ures)
>   suggest to let user mode know this limitation.=20
>     define a macro in public header (user mode can know it) and give =
comments.
>     use macro instead of number.
>     remove the comments which is inside internal function.
>=20
>   thanks.
>=20
> gchen.
>=20
>=20
>> Reported-by: Chen Gang <gang.chen@asianux.com>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> ---
>>  net/ipv4/ipmr.c |    4 ++++
>>  1 file changed, 4 insertions(+)
>>
>> diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
>> index 6168c4d..3eab2b2 100644
>> --- a/net/ipv4/ipmr.c
>> +++ b/net/ipv4/ipmr.c
>> @@ -1318,6 +1318,10 @@ int ip_mroute_setsockopt(struct sock *sk, int=
 optname, char __user *optval, unsi
>>  		if (get_user(v, (u32 __user *)optval))
>>  			return -EFAULT;
>> =20
>> +		/* "pimreg%u" should not exceed 16 bytes (IFNAMSIZ) */
>> +		if (v !=3D RT_TABLE_DEFAULT && v >=3D 1000000000)
>> +			return -EINVAL;
>> +
>>  		rtnl_lock();
>>  		ret =3D 0;
>>  		if (sk =3D=3D rtnl_dereference(mrt->mroute_sk)) {
>>
>>
>>
>>
>=20
>=20


--=20
Chen Gang

Asianux Corporation
