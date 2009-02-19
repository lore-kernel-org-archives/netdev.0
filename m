From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] iptables: lock free counters
Date: Thu, 19 Feb 2009 15:56:18 -0800
Message-ID: <499DF1A2.1030405@hp.com>
References: <20090218051906.174295181@vyatta.com>	<20090218052747.321329022@vyatta.com>	<20090219114719.560999b5@extreme> <499DEF49.3040602@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <499DEF49.3040602@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Stephen Hemminger a =E9crit :
>=20
>>The reader/writer lock in ip_tables is acquired in the critical path =
of
>>processing packets and is one of the reasons just loading iptables ca=
n cause
>>a 20% performance loss. The rwlock serves two functions:
>>
>>1) it prevents changes to table state (xt_replace) while table is in =
use.
>>   This is now handled by doing rcu on the xt_table. When table is
>>   replaced, the new table(s) are put in and the old one table(s) are=
 freed
>>   after RCU period.
>>
>>2) it provides synchronization when accesing the counter values.
>>   This is now handled by swapping in new table_info entries for each=
 cpu
>>   then summing the old values, and putting the result back onto one
>>   cpu.  On a busy system it may cause sampling to occur at different
>>   times on each cpu, but no packet/byte counts are lost in the proce=
ss.
>>
>>Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
>=20
>=20
> Acked-by: Eric Dumazet <dada1@cosmosbay.com>
>=20
> Sucessfully tested on my dual quad core machine too, but iptables onl=
y (no
> ipv6 here)
>=20
> BTW, my new "tbench 8" result is 2450 MB/s, (it was 2150 MB/s not so =
long ago)
>=20
> Thanks Stephen, thats very cool stuff, yet another rwlock out of kern=
el :)

Do you folks need/want further testing against the 32-core setup?

rick jones

>=20
>=20
>>---
>>Added missing preempt_enable.  Patch against nf-next-2.6 git tree.
>>
>> include/linux/netfilter/x_tables.h |    6 +
>> net/ipv4/netfilter/arp_tables.c    |  115 ++++++++++++++++++++++++++=
+--------
>> net/ipv4/netfilter/ip_tables.c     |  120 ++++++++++++++++++++++++++=
-----------
>> net/ipv6/netfilter/ip6_tables.c    |  119 +++++++++++++++++++++++++-=
----------
>> net/netfilter/x_tables.c           |   26 ++++++--
>> 5 files changed, 284 insertions(+), 102 deletions(-)
>>
>=20
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netfilter-d=
evel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
