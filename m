From: Li Wei <lw@cn.fujitsu.com>
Subject: Re: [PATCH] ipv6: fix incorrect route 'expires' value passed to userspace.
Date: Tue, 17 Jul 2012 09:53:35 +0800
Message-ID: <5004C59F.50702@cn.fujitsu.com>
References: <5003CC41.9080204@cn.fujitsu.com> <20120716094124.0040561f@s6510.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64025 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750906Ab2GQByX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 21:54:23 -0400
In-Reply-To: <20120716094124.0040561f@s6510.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012-7-17 0:41, Stephen Hemminger =E5=86=99=E9=81=93:
> On Mon, 16 Jul 2012 16:09:37 +0800
> Li Wei <lw@cn.fujitsu.com> wrote:
>=20
>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>> index becb048..a7fec9d 100644
>> --- a/net/ipv6/route.c
>> +++ b/net/ipv6/route.c
>> @@ -2516,7 +2516,7 @@ static int rt6_fill_node(struct net *net,
>>  		goto nla_put_failure;
>>  	if (!(rt->rt6i_flags & RTF_EXPIRES))
>>  		expires =3D 0;
>> -	else if (rt->dst.expires - jiffies < INT_MAX)
>> +	else if ((int)(rt->dst.expires - jiffies) < INT_MAX)
>>  		expires =3D rt->dst.expires - jiffies;
>>  	else
>>  		expires =3D INT_MAX;
>=20
> Why not use time_is_after_jiffies() macro?

time_is_after_jiffies() return a bool but we need "how much time
before/after jiffies" here.

>=20
>=20

However, I also think these code seems a little ugly, because we
need to store the result of two "unsigned long"'s subtraction into
an integer. Maybe we should distinguish expires before and after=20
jiffies to proper process the overflows.

Thanks,
Wei
