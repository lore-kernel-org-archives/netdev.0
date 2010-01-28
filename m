From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] sctp: IPsec rules are ineffective with ipv6
Date: Thu, 28 Jan 2010 11:36:33 -0500
Message-ID: <4B61BD11.5020303@hp.com>
References: <4B6049EB.8030803@dev.6wind.com> <20100128.055148.127214200.davem@davemloft.net> <4B61AC22.2050907@hp.com> <4B61B047.10908@dev.6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: nicolas.dichtel@dev.6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:38301 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755812Ab0A1Qgi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2010 11:36:38 -0500
In-Reply-To: <4B61B047.10908@dev.6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Nicolas Dichtel wrote:
> What about this one?
>=20
> Only compilation tested.
>=20
> xfrm_lookup() is missing in IPv6 output path. Call it when dst is bui=
ld.
> Initial patch was written by Junwei Zhang <junwei.zhang@6wind.com>
>=20
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Looks like it might do the right thing.  Please run your tests
on this an let me.

Thanks
-vlad

>=20
> Le 28.01.2010 16:24, Vlad Yasevich a =E9crit :
>>
>> David Miller wrote:
>>> From: Nicolas Dichtel <nicolas.dichtel@dev.6wind.com>
>>> Date: Wed, 27 Jan 2010 15:12:59 +0100
>>>
>>>> xfrm_lookup() is missing in sctp_v6_xmit(), add it.
>>>>
>>>> Signed-off-by: Junwei Zhang <junwei.zhang@6wind.com>
>>>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>>> Doing this every transmit packet is overkill.
>>>
>>> Whatever calculates the route that ends up in skb_dst(skb)
>>> should be making this xfrm_lookup() call, not here.
>>>
>>
>>
>> Hmm.. Interesting.  Looks like ip_route_output_key() will
>> do xfrm_lookup for you, but there is no ipv6 route lookup call
>> that will do the same thing.
>>
>> I guess we'll need to add an xfrm_lookup call in sctp_v6_get_dst().
>>
>> -vlad


