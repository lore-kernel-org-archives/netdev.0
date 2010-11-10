From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] macvlan: lockless tx path
Date: Wed, 10 Nov 2010 09:53:27 -0800
Message-ID: <4CDADC17.6070506@candelatech.com>
References: <1289403709.2860.216.camel@edumazet-laptop>	 <4CDAD8C8.20807@candelatech.com> <1289411027.2860.248.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:33569 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754361Ab0KJRxd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 12:53:33 -0500
In-Reply-To: <1289411027.2860.248.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/10/2010 09:43 AM, Eric Dumazet wrote:
> Le mercredi 10 novembre 2010 =C3=A0 09:39 -0800, Ben Greear a =C3=A9c=
rit :
>
>>>    /**
>>> - *	struct macvlan_rx_stats - MACVLAN percpu rx stats
>>> + *	struct macvlan_pcpu_stats - MACVLAN percpu stats
>>>     *	@rx_packets: number of received packets
>>>     *	@rx_bytes: number of received bytes
>>>     *	@rx_multicast: number of received multicast packets
>>> + *	@tx_
>>
>> Minor nit..seems you missed a few there?
>>
>
> Arg... you're right !
>
>>>     *	@syncp: synchronization point for 64bit counters
>>>     *	@rx_errors: number of errors
>>>     */
>>> -struct macvlan_rx_stats {
>>> +struct macvlan_pcpu_stats {
>>>    	u64			rx_packets;
>>>    	u64			rx_bytes;
>>>    	u64			rx_multicast;
>>> +	u64			tx_packets;
>>> +	u64			tx_bytes;
>>>    	struct u64_stats_sync	syncp;
>>>    	unsigned long		rx_errors;
>>> +	unsigned long		tx_dropped;
>>
>> Any reason to not also make those u64?
>>
>
> Well, they are supposed to be not incremented often, and they are pac=
ket
> counts only, so a wrap around in less than 5 seconds is very unlikely=
=2E

I agree, but if these can be read from user-space, it can be tricky to =
make
solid code to deal with wraps when the thing wrapping can be 32 or 64 b=
its,
depending on whether the kernel is compiled 32-bit or 64-bit.

So, my preference is to use u32 or u64 so there is no guesswork involve=
d.

To be sure, this problem exists in lots of places already (/proc/net/de=
v comes to mind),
but the fewer places the better in my opinion.

That said, I don't feel too strongly about it, so if you want to keep t=
hese
stats as they are, I shall argue no more :)

Thanks,
Ben


--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

