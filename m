From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH] sctp: IPsec rules are ineffective with ipv6
Date: Fri, 29 Jan 2010 10:03:03 +0800
Message-ID: <4B6241D7.4070605@cn.fujitsu.com>
References: <4B6049EB.8030803@dev.6wind.com> <20100128.055148.127214200.davem@davemloft.net> <4B61AC22.2050907@hp.com> <4B61B047.10908@dev.6wind.com> <4B61BD11.5020303@hp.com> <4B61D699.9030008@dev.6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: nicolas.dichtel@dev.6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58671 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754998Ab0A2CBn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2010 21:01:43 -0500
In-Reply-To: <4B61D699.9030008@dev.6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas Dichtel wrote:
> Hmm, seems to not work.
> Problem is that we may have a NULL saddr in sctp_v6_get_dst().
> What about adding a new handler in struct sctp_af, like get_xfrm_dst(=
)
> that will be called after get_saddr()? In case of IPv4, it will not d=
o
> anything.

This would work for transmit SCTP packet under IPSEC, the
problem is that we can not get the correct PMTU for the
transport.Under IPv4, both transmit and the PMTU is correct.

>
>
> Regards,
> Nicolas
>
> Le 28.01.2010 17:36, Vlad Yasevich a =E9crit :
>>
>> Nicolas Dichtel wrote:
>>> What about this one?
>>>
>>> Only compilation tested.
>>>
>>> xfrm_lookup() is missing in IPv6 output path. Call it when dst is
>>> build.
>>> Initial patch was written by Junwei Zhang <junwei.zhang@6wind.com>
>>>
>>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>>
>> Looks like it might do the right thing.  Please run your tests
>> on this an let me.
>>
>> Thanks
>> -vlad
>>
>>> Le 28.01.2010 16:24, Vlad Yasevich a =E9crit :
>>>> David Miller wrote:
>>>>> From: Nicolas Dichtel <nicolas.dichtel@dev.6wind.com>
>>>>> Date: Wed, 27 Jan 2010 15:12:59 +0100
>>>>>
>>>>>> xfrm_lookup() is missing in sctp_v6_xmit(), add it.
>>>>>>
>>>>>> Signed-off-by: Junwei Zhang <junwei.zhang@6wind.com>
>>>>>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>>>>> Doing this every transmit packet is overkill.
>>>>>
>>>>> Whatever calculates the route that ends up in skb_dst(skb)
>>>>> should be making this xfrm_lookup() call, not here.
>>>>>
>>>>
>>>> Hmm.. Interesting.  Looks like ip_route_output_key() will
>>>> do xfrm_lookup for you, but there is no ipv6 route lookup call
>>>> that will do the same thing.
>>>>
>>>> I guess we'll need to add an xfrm_lookup call in sctp_v6_get_dst()=
=2E
>>>>
>>>> -vlad
>>
>>
> --=20
> To unsubscribe from this list: send the line "unsubscribe linux-sctp"=
 in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
