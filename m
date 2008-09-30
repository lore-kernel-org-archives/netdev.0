From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when gc_elasticity
 is exceeded
Date: Tue, 30 Sep 2008 19:47:22 +0200
Message-ID: <48E2662A.6030104@cosmosbay.com>
References: <20080929191254.GA20074@hmsreliant.think-freely.org> <20080930.070804.26007839.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2e.orange.fr ([80.12.242.111]:53501 "EHLO smtp2e.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753180AbYI3Rre convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2008 13:47:34 -0400
In-Reply-To: <20080930.070804.26007839.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Mon, 29 Sep 2008 15:12:54 -0400
>=20
>> 	We currently have the ability to disable our route cache secret int=
erval
>> rebuild timer (by setting it to zero), but if we do that its possibl=
e for an
>> attacker (if they guess our route cache hash secret, to fill our sys=
tem with
>> routes that all hash to the same bucket, destroying our performance.=
  This patch
>> provides a backstop for that issues.  In the event that our rebuild =
interval is
>> disabled (or very large), if any hash chain exceeds ip_rt_gc_elastic=
ity, we do
>> an emergency hash rebuild.  During the hash rebuild we:
>> 1) warn the user of the emergency
>> 2) disable the rebuild timer
>> 3) invalidate the route caches
>> 4) re-enable the rebuild timer with its old value
>=20
> I just want to clarify what my intentions were when I spoke
> with Neil about this stuff last week.
>=20
> The idea is that we can by default not rebuild the secret
> at all.
>=20
> And only when we notice that chains are growing larger than
> "(NUM_RTCACHE_ENTRIES / NUM_HASH_CHAINS) * N", only then
> do we do this secret rebuild and flush.  Where N is some
> constant of configurable value, the GC elasticity is some
> example.
>=20
> Normally this whole hash secret business is totally unnecessary and
> there is zero reason to do it until we notice there is actually some
> kind of deep hash chain growth problem.
>=20
> It's expensive, we flush the whole routing cache, so doing it
> every so often by default makes no sense and it is causing
> performance problems for people.

Intentions are very good, thanks for clarifying and letting us know.




