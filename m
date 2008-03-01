From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Patch: [NET]: Remove CONFIG_PROC_FS depency for pcounter inuse
Date: Sat, 01 Mar 2008 13:02:31 +0100
Message-ID: <47C945D7.7050601@cosmosbay.com>
References: <47C8E777.5050804@hartkopp.net> <47C91BC6.6050603@cosmosbay.com> <47C93C76.5090905@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from neuf-infra-smtp-out-sp604006av.neufgp.fr ([84.96.92.121]:42332
	"EHLO neuf-infra-smtp-out-sp604006av.neufgp.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754499AbYCAMCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Mar 2008 07:02:39 -0500
In-Reply-To: <47C93C76.5090905@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Hartkopp a =E9crit :
> Eric Dumazet wrote:
>> Oliver Hartkopp a =E9crit :
>>> Hi all,
>>>
>>> attached you'll find a patch that fixes the depency that has been=20
>>> introduced in commit 65f7651788e18fadb2fbb7276af935d7871e1803 ([NET=
]:=20
>>> prot_inuse cleanups and optimizations).
>>>
>>> As the inuse counters are only used by internet protocols right now=
,=20
>>> using CONFIG_INET would have been more obvious to recognize this=20
>>> illegal optimization here. Going a bit deeper into this problem we=20
>>> can see, that the pcounters are ONLY used for the internet protocol=
s=20
>>> BUT initialized for ALL protocols in proto_[un|]register() in=20
>>> net/core/sock.c.
>>>
>>> This forces all network protocols to initialize the pcounters and=20
>>> therefore request dynamic percpu memory even when it is not used at=
 all.
>>>
>>> I would suggest to
>>>
>>> 1. move the ..._inuse_[init|free]() stuff from sock.c to=20
>>> af_inet[|6].c and his friends
>>>
>>> OR
>>>
>>> 2. add new parameters to proto_[un|]register() like 'alloc_inuse' a=
nd=20
>>> 'free_inuse'
>>>
>>> My favourite sollution would be the second one but before creating =
a=20
>>> patch for one of these suggestions, i wanted to ask for your opinio=
n=20
>>> or if there is any 'even nicer' idea from your side.
>>
>> Hello Oliver
>>
>> I am just coming back from hollidays.
>=20
> Lucky guy ;-)
>=20
>>
>> Last thing I did before leaving was to post a patch to correct=20
>> performance hit of percpu_counters in mainline. ([PATCH]=20
>> alloc_percpu() fails to allocate percpu data=20
>> http://lkml.org/lkml/2008/2/21/254 )
>>
>> Before accepting Andrew Morton claims about percpu_counters being=20
>> superior to pcounter, I benched them and found they were not.
>>
>> As soon as percpu_counters are not grossly inefficient, the only mov=
e=20
>> will be to just zap pcounter, as most people dont like it.
>>
>> Only one patch will be necessary, please dont try to hide pcounter b=
y=20
>> small patches :)
>=20
> Hm - i followed the discussion in it's major parts but my RFC hit's t=
he=20
> question whether the integration of the what-ever-per-cpu-counter=20
> initialisation in proto_register() and proto_unregister() is the righ=
t=20
> way as only the internet protocols (v4/v6) are using inuse counters=20
> these days.
>=20
> It's not about the counter implementation but the integration/usage i=
n=20
> the networking subsystem.
>=20
> Or does your mentioned patch mean, that the added functions in=20
> proto_[un|]register() will also be reverted?
>=20

A patch will make inet use percpu_counter instead of pcounter.

Then a zap patch will delete lib/pcounter.c & include/linux/pcounter.h

I dont understand why you say CONFIG_PROC_FS is *forced*.

I can build a kernel with CONFIG_PROC_FS=3Dn, with working INET.
