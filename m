From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Regression caused by commit "netfilter: iptables: lock free counters"
Date: Sun, 05 Apr 2009 14:34:50 +0200
Message-ID: <49D8A56A.8050606@cosmosbay.com>
References: <20090329234702.4988017f@desktop.r000n.info> <8763hja8cy.fsf@newton.gmurray.org.uk> <20090405.012237.198610462.davem@davemloft.net> <49D88162.5040809@cosmosbay.com> <alpine.LSU.2.00.0904051328030.7501@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, graham@gmurray.org.uk,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.00.0904051328030.7501@fbirervta.pbzchgretzou.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan Engelhardt a =E9crit :
> On Sunday 2009-04-05 12:01, Eric Dumazet wrote:
>> This could probably be solved using a single "table" containing
>> rules only, that could be shared for every cpus. Only counters
>> should be percpu. This should save a lot of ram, over previous
>> situation (2.6.29 or current one)
>=20
> Why would counters stay separate?
>=20
> I recognize all of this table copying is related to do NUMA
> optimizations, and I think I heard cache bouncing too somewhere else.
>=20
> [ http://marc.info/?l=3Dnetfilter-devel&m=3D119903624211253&w=3D2 ]
>=20
>=20

Not only NUMA, but SMP too. counters are integrated in rules themselves=
=2E
So in order to avoid ping pongs between cpus, we choose to allocate
one copy of rules/counters per cpu.

But with some changes, we could let the rules read-only and shared by
all cpus, and shadow counters only on percpu variables, thus reducing
memory costs.


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
