From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH v2 2/2] ipv4/GRO: Make GRO conform to RFC 6864
Date: Wed, 06 Apr 2016 15:30:07 -0400 (EDT)
Message-ID: <20160406.153007.1347001580998282428.davem@davemloft.net>
References: <CALx6S34Sqp7tnmkPRWH0RF_CKrBLLNWFjHbr6Uq2r=6=scMMow@mail.gmail.com>
	<20160406.114339.1083222124758102992.davem@davemloft.net>
	<CALx6S36h4nZy10=dzfjgEgyXzokEfiteSNM_L3k4jFgg9-kgYA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ecree@solarflare.com, herbert@gondor.apana.org.au,
	alexander.duyck@gmail.com, aduyck@mirantis.com, jesse@kernel.org,
	edumazet@google.com, netdev@vger.kernel.org
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44417 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753057AbcDFTaK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 15:30:10 -0400
In-Reply-To: <CALx6S36h4nZy10=dzfjgEgyXzokEfiteSNM_L3k4jFgg9-kgYA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Wed, 6 Apr 2016 14:42:26 -0300

> On Wed, Apr 6, 2016 at 12:43 PM, David Miller <davem@davemloft.net> wrote:
>> From: Tom Herbert <tom@herbertland.com>
>> Date: Wed, 6 Apr 2016 10:53:52 -0300
>>
>>> Packets that are forwarded really should not be GRO'ed in the first
>>> place because of the loss of information and added latency.
>>
>> First of all GRO is supposed to be lossless, so please stop saying this
>> would be a reason to turn it off on a router.
>>
>> Second of all, the biggest piece of overhead is the routing lookup,
>> therefore GRO batching helps enormously with routing workloads, and
>> therefore is appropriate to be enabled on routers.
>>
>> Yes, I agree that for locally terminated stuff it helps more, but don't
>> turn this into a "GRO on routers, meh..." type argument.  It simply is
>> not true at all.
>>
> GRO on routers will help in a limited case where there is little load
> and the traffic is nicely groomed high tput TCP connections. But for
> routers with significant load, handling large quantities other
> protocols like UDP, GRO is not necessarily helpful and presents a
> nondeterministic performance improvement. For instance, I cannot
> provision a router with any assumptions that GRO will be effective for
> any % of packets to save any % of CPU, we need to provision based
> purely on ability to forward by pps assuming no benefit from GRO.

Just because you cannot predict how effective a facility will be,
that doesn't mean you shouldn't use it at all.
