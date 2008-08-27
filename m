From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: cat /proc/net/tcp takes 0.5 seconds on x86_64
Date: Thu, 28 Aug 2008 01:09:19 +0200
Message-ID: <48B5DE9F.4010000@cosmosbay.com>
References: <87zlmyr5nz.fsf@basil.nowhere.org>	<20080827.142941.50104491.davem@davemloft.net>	<20080827223410.GC26610@one.firstfloor.org> <20080827.153907.157997966.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: andi@firstfloor.org, davej@redhat.com, netdev@vger.kernel.org,
	j.w.r.degoede@hhs.nl
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2f.orange.fr ([80.12.242.152]:6469 "EHLO smtp2f.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753918AbYH0XJ2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 19:09:28 -0400
In-Reply-To: <20080827.153907.157997966.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Andi Kleen <andi@firstfloor.org>
> Date: Thu, 28 Aug 2008 00:34:10 +0200
>=20
>> It fixes an old performance problem at least. I'm not aware=20
>> of any new ones in this area because the code in this=20
>> function hasn't changed since I last looked.
>=20
> That's exactly what this thread is about, things got slower for
> some reason even though nothing specifically changed in this area.
>=20
> I wonder if indirectly something changed in how the hash table
> allocator code down in mm/*.c works, perhaps it's taking NUMA
> into account differently now?
>=20

Not really, I suspect commit (a7ab4b501f9b8a9dc4d5cee542db67b6ccd1088b=20
[TCPv4]: Improve BH latency in /proc/net/tcp) is responsible for longer=
 delays.
Note that its rather old :
Date:   Sun Jun 10 17:33:08 2007 -0700


We used to disable bh once, while reading the table. This sucked.

In case machine is handling trafic, we now are preemptable by softirqs
while reading /proc/net/tcp. Thats a good thing.

By the way, I find Andi patch usefull. Same thing could be done for /pr=
oc/net/rt_cache.



