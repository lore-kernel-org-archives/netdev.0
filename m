From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: Re: [PATCH] IPv6: Fix the data length of get destination options
 with short length
Date: Thu, 29 May 2008 09:29:15 +0800
Message-ID: <483E06EB.6060503@cn.fujitsu.com>
References: <483D0070.2090909@cn.fujitsu.com> <20080528.201322.26342915.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60340 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753381AbYE2Ba2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 May 2008 21:30:28 -0400
In-Reply-To: <20080528.201322.26342915.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> In article <483D0070.2090909@cn.fujitsu.com> (at Wed, 28 May 2008 14:=
49:20 +0800), Yang Hongyang <yanghy@cn.fujitsu.com> says:
>=20
>>   If get destination options with length which is not enough for tha=
t
>> option,getsockopt() will still return the real length of the option,
>> which is larger then the buffer space.
>>   This is because ipv6_getsockopt_sticky() returns the real length o=
f
>> the option.
>>
>> This patch fix this problem.
>=20
> POSIX says that the object pointed to by the option_len argument shal=
l be
> modified to indicate the actual length of the value.
> Do you think this change conforms to the spec?
>=20
> --yoshfuji
>=20
>=20

We use the codes below to get the destination options,the length cnt is=
 half of the option length.
	cnt =3D sizeof(incmsg) / 2;
	if (getsockopt(sk, IPPROTO_IPV6, IPV6_DSTOPTS,
		       (char *)incmsg, &cnt) =3D=3D -1)=20

We can see from net/ipv6/ipv6_sockglue.c,the code below store half of t=
he option length to incmsg,
so the acture data length of incmsg is half of the option length.Accord=
ing to RFC the cnt should=20
specfy the data length of incmsg.that is half of the option length.So w=
e should return len=20
instead of ipv6_optlen(hdr).
 832         len =3D min_t(unsigned int, len, ipv6_optlen(hdr));
 833         if (copy_to_user(optval, hdr, len))
 834                 return -EFAULT;


--=20
Regards
Yang Hongyang

