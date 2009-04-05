From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] netfilter: ip6tables fix
Date: Sun, 05 Apr 2009 14:40:27 +0200
Message-ID: <49D8A6BB.5000700@cosmosbay.com>
References: <20090329234702.4988017f@desktop.r000n.info>	<8763hja8cy.fsf@newton.gmurray.org.uk>	<20090405.012237.198610462.davem@davemloft.net>	<49D88162.5040809@cosmosbay.com> <87ws9z8l4c.fsf@newton.gmurray.org.uk> <49D88839.4090902@cosmosbay.com> <49D8A445.4060201@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Graham Murray <graham@gmurray.org.uk>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754345AbZDEMky@vger.kernel.org>
In-Reply-To: <49D8A445.4060201@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet a =E9crit :
> Eric Dumazet a =E9crit :
>> Graham Murray a =E9crit :
>>> iptables gives me no problems at all, it is just ip6tables that
>>> fails. The first indication of this is during the init scripts when
>>> ip6tables-restore fails.
>> I see, its a plain bug in net/ipv6/netfilter/ip6_tables.c
>> function alloc_counters() always returns -ENOMEM
>>
>> Unfortunatly , its Sunday here and I have to run for lunch time with=
 family :)
>>
>> If nobody beats me, I will do the fix in a couple of hours...
>=20
> Here is the fix, thanks Graham for the report !
>=20
> [PATCH] netfilter: ip6tables fix
>=20
> ip6_tables.c	 alloc_counters() misses a return statement, making
> ip6tables -N always failing and leaking memory.

Oh well, this ChangeLog is not correct :(

Here is an updated patch with correct ChangeLog, sorry David.
(-L instead of -N, and there was no memory leak involved)

[PATCH] netfilter: ip6tables fix

ip6_tables.c alloc_counters() misses a return statement, making
ip6tables -L always failing.

Reported-by: Graham Murray <graham@gmurray.org.uk>
Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---

diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_t=
ables.c
index dfed176..800ae85 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -1033,6 +1033,8 @@ static struct xt_counters *alloc_counters(struct =
xt_table *table)
=20
 	xt_free_table_info(info);
=20
+	return counters;
+
  free_counters:
 	vfree(counters);
  nomem:
