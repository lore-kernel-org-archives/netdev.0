From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: cat /proc/net/tcp takes 0.5 seconds on x86_64
Date: Thu, 28 Aug 2008 09:13:13 +0200
Message-ID: <48B65009.5040805@cosmosbay.com>
References: <20080827144800.5f9fc5b4@extreme>	<20080827.150955.118944272.davem@davemloft.net>	<48B643C3.9040502@cosmosbay.com> <20080827.235158.187658055.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, andi@firstfloor.org, davej@redhat.com,
	netdev@vger.kernel.org, j.w.r.degoede@hhs.nl
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2e.orange.fr ([80.12.242.112]:38766 "EHLO smtp2e.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752796AbYH1HNX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 03:13:23 -0400
In-Reply-To: <20080827.235158.187658055.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Thu, 28 Aug 2008 08:20:51 +0200
>=20
>> But for route cache, it is probably doable since we added the
>> rt_genid thing in commit 29e75252da20f3ab9e132c68c9aed156b87beae6
>> ([IPV4] route cache: Introduce rt_genid for smooth cache
>> invalidation)
>>
>> If we add a hash table for each "struct net"
>> (net->ipv4.rt_hash_table), we then could do something sensible when
>> an admin writes to /proc/sys/net/ipv4/route/hash_size or at
>> rt_check_expire() time, if hash table is found to be full...
>=20
> The synchronization and implementation is not a problem for
> the route cache, I implemented this eons ago.
>=20
>> 3) In rt_check_expire(), adds some metrics to trigger an expand of t=
he
>>   hash table in case we found too many entries in it.
>=20
> This is the problem and why I didn't just commit the patch I had back
> then.
>=20
> We could not define a reasonable way to trigger hash table growth.
>=20
> GC attempts to keep a resident set of entries in the cache, and these
> heuristics are guided by the table size itself.  So if you grow the
> table too aggressively this never has a chance to work.

Maybe because of overcomplicated algos in net/ipv4/route.c, and
mixing "number of entries in cache", and "hash table size" things...

=46act is that nobody wants to have eight elements per hash bucket,
especially in case of DDOS.

>=20
> You want to respond dynamically to traffic in a reasonable amount of
> time, but you don't want to get tricked by bursts of RCU effects.
>=20

Right, but we also use process context processing instead of plain
timer soft irq things, so at least RCU effects should now be OK.

> We never came up with an algorithm that addresses all of these
> issues.

Could you give us the pointer to your previous work ?

Thank you



