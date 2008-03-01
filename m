From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: Patch: [NET]: Remove CONFIG_PROC_FS depency for pcounter inuse
Date: Sat, 01 Mar 2008 12:22:30 +0100
Message-ID: <47C93C76.5090905@hartkopp.net>
References: <47C8E777.5050804@hartkopp.net> <47C91BC6.6050603@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:30621 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756135AbYCALWd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Mar 2008 06:22:33 -0500
In-Reply-To: <47C91BC6.6050603@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Oliver Hartkopp a =E9crit :
>> Hi all,
>>
>> attached you'll find a patch that fixes the depency that has been=20
>> introduced in commit 65f7651788e18fadb2fbb7276af935d7871e1803 ([NET]=
:=20
>> prot_inuse cleanups and optimizations).
>>
>> As the inuse counters are only used by internet protocols right now,=
=20
>> using CONFIG_INET would have been more obvious to recognize this=20
>> illegal optimization here. Going a bit deeper into this problem we=20
>> can see, that the pcounters are ONLY used for the internet protocols=
=20
>> BUT initialized for ALL protocols in proto_[un|]register() in=20
>> net/core/sock.c.
>>
>> This forces all network protocols to initialize the pcounters and=20
>> therefore request dynamic percpu memory even when it is not used at =
all.
>>
>> I would suggest to
>>
>> 1. move the ..._inuse_[init|free]() stuff from sock.c to=20
>> af_inet[|6].c and his friends
>>
>> OR
>>
>> 2. add new parameters to proto_[un|]register() like 'alloc_inuse' an=
d=20
>> 'free_inuse'
>>
>> My favourite sollution would be the second one but before creating a=
=20
>> patch for one of these suggestions, i wanted to ask for your opinion=
=20
>> or if there is any 'even nicer' idea from your side.
>
> Hello Oliver
>
> I am just coming back from hollidays.

Lucky guy ;-)

>
> Last thing I did before leaving was to post a patch to correct=20
> performance hit of percpu_counters in mainline. ([PATCH]=20
> alloc_percpu() fails to allocate percpu data=20
> http://lkml.org/lkml/2008/2/21/254 )
>
> Before accepting Andrew Morton claims about percpu_counters being=20
> superior to pcounter, I benched them and found they were not.
>
> As soon as percpu_counters are not grossly inefficient, the only move=
=20
> will be to just zap pcounter, as most people dont like it.
>
> Only one patch will be necessary, please dont try to hide pcounter by=
=20
> small patches :)

Hm - i followed the discussion in it's major parts but my RFC hit's the=
=20
question whether the integration of the what-ever-per-cpu-counter=20
initialisation in proto_register() and proto_unregister() is the right=20
way as only the internet protocols (v4/v6) are using inuse counters=20
these days.

It's not about the counter implementation but the integration/usage in=20
the networking subsystem.

Or does your mentioned patch mean, that the added functions in=20
proto_[un|]register() will also be reverted?

Regards,
Oliver

