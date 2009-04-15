From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: use per-cpu spinlock rather than RCU (v3)
Date: Wed, 15 Apr 2009 12:59:03 +0200
Message-ID: <49E5BDF7.8090502@trash.net>
References: <20090411174801.GG6822@linux.vnet.ibm.com>	<18913.53699.544083.320542@cargo.ozlabs.ibm.com>	<20090412173108.GO6822@linux.vnet.ibm.com>	<20090412.181330.23529546.davem@davemloft.net>	<20090413040413.GQ6822@linux.vnet.ibm.com>	<20090413095309.631cf395@nehalam>	<49E48136.5060700@trash.net>	<49E49C65.8060808@cosmosbay.com>	<20090414074554.7fa73e2f@nehalam>	<49E4B0A5.70404@cosmosbay.com>	<b6a2187b0904140951r3c6a41fdnc26b149202bdfa84@mail.gmail.com>	<20090414111716.28585806@nehalam>	<49E4E3E8.5090201@cosmosbay.com> <20090414141351.0f63ac98@nehalam> <49E502B5.7070700@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Jeff Chua <jeff.chua.linux@gmail.com>,
	paulmck@linux.vnet.ibm.com, David Miller <davem@davemloft.net>,
	paulus@samba.org, mingo@elte.hu, torvalds@linux-foundation.org,
	laijs@cn.fujitsu.com, jengelh@medozas.de, r000n@r000n.net,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, benh@kernel.crashing.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <49E502B5.7070700@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Stephen Hemminger a =E9crit :
>> This is an alternative version of ip/ip6/arp tables locking using
>> per-cpu locks.  This avoids the overhead of synchronize_net() during
>> update but still removes the expensive rwlock in earlier versions.
>>
>> The idea for this came from an earlier version done by Eric Dumazet.
>> Locking is done per-cpu, the fast path locks on the current cpu
>> and updates counters.  The slow case involves acquiring the locks on
>> all cpu's.
>>
>> The mutex that was added for 2.6.30 in xt_table is unnecessary since
>> there already is a mutex for xt[af].mutex that is held.
>>
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>>
>> ---
>>  include/linux/netfilter/x_tables.h |    5 -
>>  net/ipv4/netfilter/arp_tables.c    |  112 +++++++++----------------=
--------
>>  net/ipv4/netfilter/ip_tables.c     |  123 +++++++++++--------------=
------------
>>  net/ipv6/netfilter/ip6_tables.c    |  119 +++++++++++--------------=
----------
>>  net/netfilter/x_tables.c           |   28 --------
>>  5 files changed, 110 insertions(+), 277 deletions(-)
>>
>=20
> Tested successfuly on my dev machine, thanks Stephen.
>=20
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks everyone. I'll give it some testing myself and
will send it upstream tonight.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
