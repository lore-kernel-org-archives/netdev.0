From: Ben Greear <greearb@candelatech.com>
Subject: Re: OOM when adding ipv6 route:  How to make available more per-cpu
 memory?
Date: Mon, 08 Nov 2010 10:08:50 -0800
Message-ID: <4CD83CB2.7070809@candelatech.com>
References: <4CD43C87.5040403@candelatech.com>	 <1288980361.2882.1070.camel@edumazet-laptop>	 <4CD449A5.5070305@candelatech.com>	 <1288988403.2665.268.camel@edumazet-laptop>	 <1288995103.2665.653.camel@edumazet-laptop>	 <4CD49C2F.3060904@candelatech.com>	 <1289028392.2665.2418.camel@edumazet-laptop>	 <4CD58B9C.2030006@candelatech.com>	 <1289214131.2820.187.camel@edumazet-laptop>	 <4CD83752.1070501@candelatech.com> <1289238912.3167.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:47364 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753386Ab0KHSIy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 13:08:54 -0500
In-Reply-To: <1289238912.3167.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/08/2010 09:55 AM, Eric Dumazet wrote:
> Le lundi 08 novembre 2010 =C3=A0 09:45 -0800, Ben Greear a =C3=A9crit=
 :
>
>> That helps.  I'm getting all of the IP addrs set now, but
>> having trouble with some of the default gateways (I have one
>> routing table per interface).
>>
>> ./local/sbin/ip -6 route replace default via 2002:9:8::1 dev eth7#45=
8 table 726
>> RTNETLINK answers: No buffer space available
>>
>> dmesg is full of this:
>>
>> [247106.294743] ipv6: Neighbour table overflow.
>>
>>
>> A quick look in /proc didn't show a tunable for this, but I'll
>> go grub through the code.
>>
>> As for the route/max_size, it would be nice to see some useful kerne=
l
>> message in dmesg when this hit.  Just telling the user '-ENOMEM'
>> is not at all sufficient to help them figure out the problem.
>
> Sure, patches are welcomed. Apparently nobody yet used ipv6 with so m=
any
> devices / routes, and this nobody contributed to extend limits.

I'll see what I can do.  I'm aiming for several thousand IPv6 addrs,
so will try to get these limitations ironed out.

>> For that matter, why is there such a limit anyway?  IPv4 doesn't app=
ear
>> to have any such limit?
>
> There are limits for ipv4, much bigger, you probably never noticed.
>
>
> /proc/sys/net/ipv4/route/gc_elasticity:8
> /proc/sys/net/ipv4/route/gc_interval:60
> /proc/sys/net/ipv4/route/gc_min_interval:0
> /proc/sys/net/ipv4/route/gc_min_interval_ms:500
> /proc/sys/net/ipv4/route/gc_thresh:131072
> /proc/sys/net/ipv4/route/gc_timeout:300
> /proc/sys/net/ipv4/route/max_size:2097152<<<  HERE
> /proc/sys/net/ipv4/route/min_adv_mss:256
> /proc/sys/net/ipv4/route/min_pmtu:552
> /proc/sys/net/ipv4/route/mtu_expires:600
> /proc/sys/net/ipv4/route/redirect_load:2
> /proc/sys/net/ipv4/route/redirect_number:9
> /proc/sys/net/ipv4/route/redirect_silence:2048
>
> I suggest followup discussion can got to netdev only, now per-cpu it =
not
> anymore the problem ?

Agreed, and trimmed.

Thanks,
Ben

--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

