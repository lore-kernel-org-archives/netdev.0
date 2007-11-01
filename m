From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] INET : removes per bucket rwlock in tcp/dccp ehash table
Date: Thu, 01 Nov 2007 20:00:33 +0100
Message-ID: <472A2251.4000701@cosmosbay.com>
References: <4729A774.9030409@cosmosbay.com>	<20071101091456.26248ce0@freepuppy.rosehill> <472A12D0.4070401@cosmosbay.com> <472A1F8A.2070708@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andi Kleen <ak@suse.de>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:58147 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754011AbXKATBL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 15:01:11 -0400
In-Reply-To: <472A1F8A.2070708@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones a =E9crit :
> Eric Dumazet wrote:
>> Stephen Hemminger a =E9crit :
>>
>>> On Thu, 01 Nov 2007 11:16:20 +0100
>>> Eric Dumazet <dada1@cosmosbay.com> wrote:
>>>
>>>> As done two years ago on IP route cache table (commit=20
>>>> 22c047ccbc68fa8f3fa57f0e8f906479a062c426) , we can avoid using one=
=20
>>>> lock per hash bucket for the huge TCP/DCCP hash tables.
>=20
> The TCP hashes are looked at with higher frequency than the route cac=
he=20
> yes?

It depends on the workload, but in general I would say the reverse.

>=20
>>>> On a typical x86_64 platform, this saves about 2MB or 4MB of ram,=20
>>>> for litle performance differences. (we hit a different cache line=20
>>>> for the rwlock, but then the bucket cache line have a better shari=
ng=20
>>>> factor among cpus, since we dirty it less often)
>>>>
>>>> Using a 'small' table of hashed rwlocks should be more than enough=
=20
>>>> to provide correct SMP concurrency between different buckets,=20
>>>> without using too much memory. Sizing of this table depends on=20
>>>> NR_CPUS and various CONFIG settings.
>=20
> Something is telling me finding a 64 core system with a suitable=20
> workload to try this could be a good thing.  Wish I had one at my dis=
posal.

If you find one, please give it to me when you finished playing^Wworkin=
g with=20
it :)


