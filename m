From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: per-cpu spin-lock with recursion (v0.8)
Date: Fri, 17 Apr 2009 13:17:13 +0200
Message-ID: <49E86539.9070408@trash.net>
References: <20090415170111.6e1ca264@nehalam>	<alpine.LFD.2.00.0904151705120.4042@localhost.localdomain>	<49E72E83.50702@trash.net>	<20090416.153354.170676392.davem@davemloft.net>	<20090416234955.GL6924@linux.vnet.ibm.com> <20090416165233.5d8bbfb5@nehalam> <49E81B9D.3030807@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	paulmck@linux.vnet.ibm.com, David Miller <davem@davemloft.net>,
	torvalds@linux-foundation.org, jeff.chua.linux@gmail.com,
	paulus@samba.org, mingo@elte.hu, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <49E81B9D.3030807@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Stephen Hemminger a =E9crit :
>> This version of x_tables (ip/ip6/arp) locking uses a per-cpu
>> recursive lock that can be nested. It is sort of like existing kerne=
l_lock,
>> rwlock_t and even old 2.4 brlock.
>>
>> ...
> I like this version 8 of the patch, as it mixes all ideas we had,
> but have two questions.
>=20
> Previous netfilter code (and 2.6.30-rc2 one too) disable BH, not only=
 preemption.
>=20
> I see xt_table_info_lock_all(void) does block BH, so this one is safe=
=2E
>=20
> I let Patrick or other tell us if its safe to run ipt_do_table()
> with preemption disabled but BH enabled, I really dont know.

No, on jumps the return position is stored in the per-cpu copy
of the ruleset and we must prevent BH context corrupting the
value of something running in process context.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
