From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] macvlan: lockless tx path
Date: Wed, 10 Nov 2010 10:40:19 -0800
Message-ID: <4CDAE713.7020309@candelatech.com>
References: <1289403709.2860.216.camel@edumazet-laptop>	 <4CDAD8C8.20807@candelatech.com>	 <1289411027.2860.248.camel@edumazet-laptop>	 <4CDADC17.6070506@candelatech.com> <1289413120.2469.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:44265 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755858Ab0KJSk1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 13:40:27 -0500
In-Reply-To: <1289413120.2469.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/10/2010 10:18 AM, Eric Dumazet wrote:
> Le mercredi 10 novembre 2010 =C3=A0 09:53 -0800, Ben Greear a =C3=A9c=
rit :
>
>> I agree, but if these can be read from user-space, it can be tricky =
to make
>> solid code to deal with wraps when the thing wrapping can be 32 or 6=
4 bits,
>> depending on whether the kernel is compiled 32-bit or 64-bit.
>>
>> So, my preference is to use u32 or u64 so there is no guesswork invo=
lved.
>>
>> To be sure, this problem exists in lots of places already (/proc/net=
/dev comes to mind),
>> but the fewer places the better in my opinion.
>>
>
> On a 32bit kernel, very few devices provide 64bit counters, so an
> application reading /proc/net/dev should be prepared to handle 32 or
> 64bit counter.
>
> On a 64bit kernel, many devices still provide 32, 36, 40 bit counters
> (hardware based). Same conclusion for userspace.

In my opinion, the kernel and/or driver should deal with this such that
at worst the user has to deal with 32 v/s 64 bits based on whether the
kernel is compiled for 32 or 64 bit CPUs.  (Let the driver sample at
intervals needed to never wrap it's counters more than once and update
software stats of well-defined bit-width, and present those software
counters to users.

In practice, this seems to be the case, at least for the NICs I've used
(mostly Intel).  But, please don't propagate the idea that any width of
counters is OK to present to user-space:  It is completely unfair to
make app writers have to know the network driver and/or hardware quirks=
 to
know how often it must sample stats.

> So really, an SNMP application must be able to cope with any counter
> width.
>
> As percpu data is going to hurt in the 4096 cpu cases, we should try =
to
> not make percpu structures too big.

Well, maybe using u32 would have positive benefits on 64-bit kernels th=
en?

Thanks,
Ben

--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

