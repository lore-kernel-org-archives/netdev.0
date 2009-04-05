From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] netfilter: ip6tables fix
Date: Sun, 05 Apr 2009 14:29:57 +0200
Message-ID: <49D8A445.4060201@cosmosbay.com>
References: <20090329234702.4988017f@desktop.r000n.info>	<8763hja8cy.fsf@newton.gmurray.org.uk>	<20090405.012237.198610462.davem@davemloft.net>	<49D88162.5040809@cosmosbay.com> <87ws9z8l4c.fsf@newton.gmurray.org.uk> <49D88839.4090902@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Graham Murray <graham@gmurray.org.uk>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:32871 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750971AbZDEMaJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Apr 2009 08:30:09 -0400
In-Reply-To: <49D88839.4090902@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> Graham Murray a =E9crit :
>> iptables gives me no problems at all, it is just ip6tables that
>> fails. The first indication of this is during the init scripts when
>> ip6tables-restore fails.
>=20
> I see, its a plain bug in net/ipv6/netfilter/ip6_tables.c
> function alloc_counters() always returns -ENOMEM
>=20
> Unfortunatly , its Sunday here and I have to run for lunch time with =
family :)
>=20
> If nobody beats me, I will do the fix in a couple of hours...

Here is the fix, thanks Graham for the report !

[PATCH] netfilter: ip6tables fix

ip6_tables.c	 alloc_counters() misses a return statement, making
ip6tables -N always failing and leaking memory.

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

