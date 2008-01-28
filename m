From: shanwei <shanwei@cn.fujitsu.com>
Subject: Re: [PATCH] TCP:Fix a bug in strategy_allowed_congestion_control
Date: Mon, 28 Jan 2008 10:05:35 +0800
Message-ID: <479D386F.5030805@cn.fujitsu.com>
References: <47998B55.1030305@cn.fujitsu.com> <20080125082553.78e1d207@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Sam Jansen <sjansen@google.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61785 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753950AbYA1CGP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Jan 2008 21:06:15 -0500
In-Reply-To: <20080125082553.78e1d207@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger =E5=86=99=E9=81=93:
> On Fri, 25 Jan 2008 15:10:13 +0800
> shanwei <shanwei@cn.fujitsu.com> wrote:
>=20
>> hi all:
>>
>> In strategy_allowed_congestion_control of the 2.6.24 kernel,=20
>> when sysctl_string return 1 on success,it should call=20
>> tcp_set_allowed_congestion_control to set the allowed congestion
>> control.But, it don't.
>> the sysctl_string return 1 on success, otherwise return negative,
>> never return 0.The patch fix the problem.
>>
>> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
>>
>> diff -Nuarp linux-2.6.24/net/ipv4/sysctl_net_ipv4.c linux-2.6.24-new=
/net/ipv4/sysctl_net_ipv4.c
>> --- linux-2.6.24/net/ipv4/sysctl_net_ipv4.c	2008-01-25 06:58:37.0000=
00000 +0800
>> +++ linux-2.6.24-new/net/ipv4/sysctl_net_ipv4.c	2008-01-25 12:23:20.=
000000000 +0800
>> @@ -248,7 +248,7 @@ static int strategy_allowed_congestion_c
>> =20
>>  	tcp_get_available_congestion_control(tbl.data, tbl.maxlen);
>>  	ret =3D sysctl_string(&tbl, name, nlen, oldval, oldlenp, newval, n=
ewlen);
>> -	if (ret =3D=3D 0 && newval && newlen)
>> +	if (ret =3D=3D 1 && newval && newlen)
>>  		ret =3D tcp_set_allowed_congestion_control(tbl.data);
>>  	kfree(tbl.data);
>>
>>
>=20
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
> This parallels previous fix by Sam Jansen.
>=20
>=20
=46rom the link:http://marc.info/?l=3Dlinux-netdev&m=3D119551836927062&=
w=3D2,
he only fix the sysctl_tcp_congestion_control function.
In the latest kernel, the sysctl_string problem is present.
Can this patch be applied?

=20

