From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] INET : removes per bucket rwlock in tcp/dccp ehash table
Date: Thu, 01 Nov 2007 11:48:42 -0700
Message-ID: <472A1F8A.2070708@hp.com>
References: <4729A774.9030409@cosmosbay.com>	<20071101091456.26248ce0@freepuppy.rosehill> <472A12D0.4070401@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andi Kleen <ak@suse.de>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:39936 "EHLO palrel11.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753273AbXKASsp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2007 14:48:45 -0400
In-Reply-To: <472A12D0.4070401@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Stephen Hemminger a =E9crit :
>=20
>> On Thu, 01 Nov 2007 11:16:20 +0100
>> Eric Dumazet <dada1@cosmosbay.com> wrote:
>>
>>> As done two years ago on IP route cache table (commit=20
>>> 22c047ccbc68fa8f3fa57f0e8f906479a062c426) , we can avoid using one=20
>>> lock per hash bucket for the huge TCP/DCCP hash tables.

The TCP hashes are looked at with higher frequency than the route cache=
 yes?

>>> On a typical x86_64 platform, this saves about 2MB or 4MB of ram, f=
or=20
>>> litle performance differences. (we hit a different cache line for t=
he=20
>>> rwlock, but then the bucket cache line have a better sharing factor=
=20
>>> among cpus, since we dirty it less often)
>>>
>>> Using a 'small' table of hashed rwlocks should be more than enough =
to=20
>>> provide correct SMP concurrency between different buckets, without=20
>>> using too much memory. Sizing of this table depends on NR_CPUS and=20
>>> various CONFIG settings.

Something is telling me finding a 64 core system with a suitable worklo=
ad to try=20
this could be a good thing.  Wish I had one at my disposal.

rick jones
