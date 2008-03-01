From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Patch: [NET]: Remove CONFIG_PROC_FS depency for pcounter inuse
Date: Sat, 01 Mar 2008 10:03:02 +0100
Message-ID: <47C91BC6.6050603@cosmosbay.com>
References: <47C8E777.5050804@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from neuf-infra-smtp-out-sp604007av.neufgp.fr ([84.96.92.120]:51698
	"EHLO neuf-infra-smtp-out-sp604007av.neufgp.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760144AbYCAJDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Mar 2008 04:03:30 -0500
In-Reply-To: <47C8E777.5050804@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Hartkopp a =E9crit :
> Hi all,
>=20
> attached you'll find a patch that fixes the depency that has been=20
> introduced in commit 65f7651788e18fadb2fbb7276af935d7871e1803 ([NET]:=
=20
> prot_inuse cleanups and optimizations).
>=20
> As the inuse counters are only used by internet protocols right now,=20
> using CONFIG_INET would have been more obvious to recognize this ille=
gal=20
> optimization here. Going a bit deeper into this problem we can see, t=
hat=20
> the pcounters are ONLY used for the internet protocols BUT initialize=
d=20
> for ALL protocols in proto_[un|]register() in net/core/sock.c.
>=20
> This forces all network protocols to initialize the pcounters and=20
> therefore request dynamic percpu memory even when it is not used at a=
ll.
>=20
> I would suggest to
>=20
> 1. move the ..._inuse_[init|free]() stuff from sock.c to af_inet[|6].=
c=20
> and his friends
>=20
> OR
>=20
> 2. add new parameters to proto_[un|]register() like 'alloc_inuse' and=
=20
> 'free_inuse'
>=20
> My favourite sollution would be the second one but before creating a=20
> patch for one of these suggestions, i wanted to ask for your opinion =
or=20
> if there is any 'even nicer' idea from your side.

Hello Oliver

I am just coming back from hollidays.

Last thing I did before leaving was to post a patch to correct performa=
nce hit=20
of percpu_counters in mainline. ([PATCH] alloc_percpu() fails to alloca=
te=20
percpu data http://lkml.org/lkml/2008/2/21/254 )

Before accepting Andrew Morton claims about percpu_counters being super=
ior to=20
pcounter, I benched them and found they were not.

As soon as percpu_counters are not grossly inefficient, the only move w=
ill be=20
to just zap pcounter, as most people dont like it.

Only one patch will be necessary, please dont try to hide pcounter by s=
mall=20
patches :)

Thank you
