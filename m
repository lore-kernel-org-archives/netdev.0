From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: cat /proc/net/tcp takes 0.5 seconds on x86_64
Date: Thu, 28 Aug 2008 11:52:48 +0200
Message-ID: <48B67570.2020704@cosmosbay.com>
References: <48B643C3.9040502@cosmosbay.com>	<20080827.235158.187658055.davem@davemloft.net>	<48B65009.5040805@cosmosbay.com> <20080828.005741.97382742.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, andi@firstfloor.org, davej@redhat.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp28.orange.fr ([80.12.242.101]:22105 "EHLO smtp28.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751997AbYH1Jwy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 05:52:54 -0400
In-Reply-To: <20080828.005741.97382742.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Thu, 28 Aug 2008 09:13:13 +0200
>=20
>> David Miller a =E9crit :
>>> We could not define a reasonable way to trigger hash table growth.
>>> GC attempts to keep a resident set of entries in the cache, and the=
se
>>> heuristics are guided by the table size itself.  So if you grow the
>>> table too aggressively this never has a chance to work.
>> Maybe because of overcomplicated algos in net/ipv4/route.c, and
>> mixing "number of entries in cache", and "hash table size" things...
>=20
> But it is exactly what we want to use to create equilabrium
> when the size is large enough.
>=20
>> Fact is that nobody wants to have eight elements per hash bucket,
>> especially in case of DDOS.
>=20
> Of this there is no doubt.  But also, nobody wants to use 1GB hash
> table simply because of poorly implemented interactions between GC an=
d
> hash table growth :-)

Sure, but we have /proc/sys/net/ipv4/route/max_size, so hash table size=
 would be
at most (sizeof(void *) * max_size) of course.

>=20
> It was a series of patches I started posting in August 2006:
>=20
> 	http://marc.info/?l=3Dlinux-netdev&m=3D115510979129323&w=3D2
>=20
> There was a bunch of discussion, the locking and synchronization
> were worked out but the resize logic was not.

Thanks David, I remembered this stuff but was unable to find it again i=
n my archives.

Give me some days/weeks to work on this subject.

(Hans removed from CC)





