From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] netfilter: use per-cpu spinlock rather than RCU (v2)
Date: Tue, 14 Apr 2009 21:28:40 +0200
Message-ID: <49E4E3E8.5090201@cosmosbay.com>
References: <20090411174801.GG6822@linux.vnet.ibm.com>	<18913.53699.544083.320542@cargo.ozlabs.ibm.com>	<20090412173108.GO6822@linux.vnet.ibm.com>	<20090412.181330.23529546.davem@davemloft.net>	<20090413040413.GQ6822@linux.vnet.ibm.com>	<20090413095309.631cf395@nehalam>	<49E48136.5060700@trash.net>	<49E49C65.8060808@cosmosbay.com>	<20090414074554.7fa73e2f@nehalam>	<49E4B0A5.70404@cosmosbay.com>	<b6a2187b0904140951r3c6a41fdnc26b149202bdfa84@mail.gmail.com> <20090414111716.28585806@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Chua <jeff.chua.linux@gmail.com>,
	Patrick McHardy <kaber@trash.net>, paulmck@linux.vnet.ibm.com,
	David Miller <davem@davemloft.net>, paulus@samba.org,
	mingo@elte.hu, torvalds@linux-foundation.org, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:51714 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752224AbZDNTam convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 15:30:42 -0400
In-Reply-To: <20090414111716.28585806@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> Subject: iptables:=20
>=20
> This is an alternative version of ip/ip6/arp tables locking using
> per-cpu locks.  This avoids the overhead of synchronize_net() during
> update but still removes the expensive rwlock in earlier versions.
>=20
> The idea for this came from an earlier version done by Eric Duzamet.
> Locking is done per-cpu, the fast path locks on the current cpu
> and updates counters.  The slow case involves acquiring the locks on
> all cpu's.
>=20
> The mutex that was added for 2.6.30 in xt_table is unnecessary since
> there already is a mutex for xt[af].mutex that is held.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
> ---
>  include/linux/netfilter/x_tables.h |    5 -
>  net/ipv4/netfilter/arp_tables.c    |  112 +++++++++-----------------=
-------
>  net/ipv4/netfilter/ip_tables.c     |  123 +++++++++++---------------=
-----------
>  net/ipv6/netfilter/ip6_tables.c    |  119 +++++++++++---------------=
---------
>  net/netfilter/x_tables.c           |   28 --------
>  5 files changed, 110 insertions(+), 277 deletions(-)

Oh well, it seems factorization of this stuff is not what you want, so
I'll stop arguing.

Please check spelling of my name in ChangeLog, and more importantly :
initialize arp_tables_lock that is missing in V1/2

	for_each_possible_cpu(cpu)
		spin_lock_init(&per_cpu(arp_tables_lock, cpu));

Then please add my :

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Thanks


