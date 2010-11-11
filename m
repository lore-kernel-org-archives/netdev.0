From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] macvlan: lockless tx path
Date: Thu, 11 Nov 2010 09:20:53 -0800
Message-ID: <4CDC25F5.7010501@candelatech.com>
References: <1289403709.2860.216.camel@edumazet-laptop>	 <4CDAD8C8.20807@candelatech.com>	 <1289411027.2860.248.camel@edumazet-laptop>	 <4CDADC17.6070506@candelatech.com>	 <1289413120.2469.12.camel@edumazet-laptop>	 <4CDAE713.7020309@candelatech.com>	 <1289421187.2469.127.camel@edumazet-laptop> <4CDB1021.507@candelatech.com>	 <1289427705.17691.52.camel@edumazet-laptop>	 <4CDB226A.8080903@candelatech.com>	 <1289432184.17691.141.camel@edumazet-laptop>	 <4CDB2EBC.2090905@candelatech.com>	 <1289459012.17691.1001.camel@edumazet-laptop>	 <4CDC1C9A.3070102@candelatech.com> <1289494618.17691.1498.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:59515 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754646Ab0KKRUz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 12:20:55 -0500
In-Reply-To: <1289494618.17691.1498.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/11/2010 08:56 AM, Eric Dumazet wrote:
> Le jeudi 11 novembre 2010 =C3=A0 08:40 -0800, Ben Greear a =C3=A9crit=
 :
>
>> So, they assume counters are exactly 32 or 64 bits.
>> Your example of the 36-bit counter would break their
>> assumptions of 32 or 64 bits.
>>
>
> They 'assume'. I am not. How do you handle counters that suddenly go =
to
> 0 ?

I've shown you my algorithm that requires one to know the counter
width, and in response you offered on that will work with 32 OR 64 bits=
,
as long as you make some assumptions.

If you have an algorithm that can properly deal with wrapped counters o=
f
arbitrary bits, then post it.

As for counters that go to zero, if the previous value was > 0, then
it was a wrap.  There is a reason Dave won't let anyone add a patch to
clear network counters.  If the network device was removed and came bac=
k,
then you must listen for those events and take proper precautions (set
prev to 0 before sampling any counters, for instance).


>> I agree that you can guess if the counter is 32 or 64, at least with=
 today's
>> hardware and relatively normal poll times, and the requirement that =
the
>> counters can ONLY be 32 or 64 bits.  I still consider it a kludge to
>> return 32 bit counters in stats64, however.  Would you consider
>> a patch to have netlink pay attention to whether the stats are 32 or
>> 64 (based on a flag returned from dev_get_stats perhaps)?
>
> So what ? How is it going to help /proc/net/dev users (most apps use =
it)

At least they will have an opportunity to use a better defined API
if they wish.  And, if you only want stats for one interface, and
you have 4000 VLANs in the system, reading /proc/net/dev seems quite
inefficient.

> Could you please adapt your software, and not adapt linux to your
> needs ? Dont your software runs on linux 2.6.32 ?

Yes, I used to carry a patch that allowed direct access to the netdev_s=
tats,
and I'd fall back to parsing /proc/net/dev on standard kernels.  I've n=
ow
moved to using netlink API as that seems the preferred method going
forward and allows the granularity (ie, get stats for a single device)
that I prefer.

And, I'll certainly keep trying to improve Linux, because if it helps
my needs, it may help others.  If it causes harm to others, then hopefu=
lly
someone will notice and reject my patch or help me to see how to make
it better.

Thanks,
Ben

--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

