From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when
	gc_elasticity is exceeded
Date: Tue, 30 Sep 2008 14:42:49 -0400
Message-ID: <20080930184249.GC6496@hmsreliant.think-freely.org>
References: <48E141F3.9000903@cosmosbay.com> <20080929223801.GA3157@hmsreliant.think-freely.org> <48E1C104.2080801@cosmosbay.com> <20080930.071023.07946874.davem@davemloft.net> <48E25F02.8030303@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50801 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754102AbYI3SpE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2008 14:45:04 -0400
Content-Disposition: inline
In-Reply-To: <48E25F02.8030303@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 30, 2008 at 07:16:50PM +0200, Eric Dumazet wrote:
> David Miller a =E9crit :
>> From: Eric Dumazet <dada1@cosmosbay.com>
>> Date: Tue, 30 Sep 2008 08:02:44 +0200
>>
>>> When a machine is targeted by a DDOS attack, about all slots of the
>>> hash table are fully loaded (ie chain length >=3D elasticity). We d=
ont
>>> need to invalidate the cache, but find an equilibrium, with small
>>> adjustements.
>>
>> Sure, but it is possible to determine that some hash chains
>> are unevenly growing out of control compared to others,
>> and that is the algorithm that Neil is trying to discover.
>>
>>
>
> No problem, but my suggestion to use a separate threshold than elasti=
city
> was apparently not taken into consideration.
>
> I ran an experiment on a big stable machine with 2^19 rtcache slots,
> scanning all chains and found *many* of them having length > elastici=
ty,
> maximum being 13. I am sure its allowed by statistics laws.
>
> (average chain length : 3.55)
>
> In order to avoid unecessary cache invalidation, we need some =20
> calculation from a statistics expert.
>
> Given rt_hash_size and elasticity (or rt_max_size), compute the "maxi=
mum=20
> reasonable" chain length, ie some X number where probability(chain_le=
ngth=20
> < X) > 0.9999
>
I think what you're looking for here is a simple standard deviation, is=
n't it?
Compute the mean chain legnth, sum the squares of the deviations of eac=
h chain
and take the square root.  Any individual chain longer than the mean ch=
ain
length + 1 standard deviation can be considered an 'outlier' and theref=
ore
trigger a rebuild of the table for that net namespace.

I full well realize that thats easier said than done, but does that see=
m about
right?  If so, I can start working on trying to build something to acco=
mplish
that.

Regards
Neil


--=20
/****************************************************
 * Neil Horman <nhorman@tuxdriver.com>
 * Software Engineer, Red Hat
 ****************************************************/
