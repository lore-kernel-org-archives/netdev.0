From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: Re: [PATCH] netfilter: use per-cpu recursive lock (v11)
Date: Tue, 21 Apr 2009 13:34:51 +0800
Message-ID: <49ED5AFB.2090709@cn.fujitsu.com>
References: <alpine.LFD.2.00.0904151705120.4042@localhost.localdomain>	<49E72E83.50702@trash.net>	<20090416.153354.170676392.davem@davemloft.net>	<20090416234955.GL6924@linux.vnet.ibm.com>	<20090417012812.GA25534@linux.vnet.ibm.com>	<20090418094001.GA2369@ioremap.net>	<20090418141455.GA7082@linux.vnet.ibm.com>	<20090420103414.1b4c490f@nehalam>	<49ECBE0A.7010303@cosmosbay.com>	<18924.59347.375292.102385@cargo.ozlabs.ibm.com>	<20090420215827.GK6822@linux.vnet.ibm.com>	<18924.64032.103954.171918@cargo.ozlabs.ibm.com> <20090420160121.268a8226@nehalam> <49ED406F.2040401@cn.fujitsu.com> <49ED4407.8010200@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Paul Mackerras <paulus@samba.org>, paulmck@linux.vnet.ibm.com,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	torvalds@linux-foundation.org, jeff.chua.linux@gmail.com,
	mingo@elte.hu, jengelh@medozas.de, r000n@r000n.net,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, benh@kernel.crashing.org,
	mathieu.desnoyers@polymtl.ca
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <49ED4407.8010200@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Lai Jiangshan a =C3=A9crit :
>> Stephen Hemminger wrote:
>>> +/**
>>> + * xt_table_info_rdlock_bh - recursive read lock for xt table info
>>> + *
>>> + * Table processing calls this to hold off any changes to table
>>> + * (on current CPU). Always leaves with bottom half disabled.
>>> + * If called recursively, then assumes bh/preempt already disabled=
=2E
>>> + */
>>> +void xt_info_rdlock_bh(void)
>>> +{
>>> +	struct xt_info_lock *lock;
>>> +
>>> +	preempt_disable();
>>> +	lock =3D &__get_cpu_var(xt_info_locks);
>>> +	if (likely(++lock->depth =3D=3D 0))
>> Maybe I missed something. I think softirq may be still enabled here.
>> So what happen when xt_info_rdlock_bh() called recursively here?
>=20
> well, first time its called, you are right softirqs are enabled until
> the point we call spin_lock_bh(), right after this line :
>=20
>=20

Which context can enter the critical region?
Can irq and softirq? or softirq only?

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
