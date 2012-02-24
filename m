From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH] ipv6: Fix problem with expired dst cache
Date: Fri, 24 Feb 2012 17:27:44 +0800
Message-ID: <4F475810.5050001@cn.fujitsu.com>
References: <1330064404-24763-1-git-send-email-gaofeng@cn.fujitsu.com> <20120224.014716.2237525226945856862.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54904 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754497Ab2BXJ0y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2012 04:26:54 -0500
In-Reply-To: <20120224.014716.2237525226945856862.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B402=E6=9C=8824=E6=97=A5 14:47, David Miller =E5=86=
=99=E9=81=93:
> From: Gao feng <gaofeng@cn.fujitsu.com>
> Date: Fri, 24 Feb 2012 14:20:04 +0800
>=20
>> diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
>> index b26bb81..3da4d58c 100644
>> --- a/include/net/ip6_fib.h
>> +++ b/include/net/ip6_fib.h
>> @@ -106,6 +106,7 @@ struct rt6_info {
>>  	u32				rt6i_metric;
>>  	u32				rt6i_peer_genid;
>> =20
>> +	struct rt6_info			*rt6i_copy;
>>  	struct inet6_dev		*rt6i_idev;
>>  	struct inet_peer		*rt6i_peer;
>=20
> This bloats up every route and cached entry in the machine, find
> another way.
>=20

How about calling rt6_get_dflt_route to find out the default dst,
and check if it has expired when we use the cache dst?
