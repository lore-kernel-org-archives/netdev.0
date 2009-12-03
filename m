From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] tcp: connect() race with timewait reuse
Date: Thu, 03 Dec 2009 07:44:53 +0100
Message-ID: <4B175E65.3070905@gmail.com>
References: <99d458640911301802i4bde20f4wa314668d543e3170@mail.gmail.com> <4B152F97.1090409@gmail.com> <20091202.005937.177088443.davem@davemloft.net> <4B163226.50801@gmail.com> <4B164293.7070804@gmail.com> <4B16830B.4010801@gmail.com> <20091202221552.GA17579@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, kdakhane@gmail.com,
	netdev@vger.kernel.org, netfilter@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <20091202221552.GA17579@ioremap.net>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov a =E9crit :
> Hi.
>=20
> Looks very good, thanks Eric, I have one question.
>=20
> On Wed, Dec 02, 2009 at 04:08:59PM +0100, Eric Dumazet (eric.dumazet@=
gmail.com) wrote:
>> +
>> +/*
>> + * unhash a timewait socket from established hash
>> + * lock must be hold by caller
>> + */
>> +void inet_twsk_unhash(struct inet_timewait_sock *tw)
>> +{
>> +	if (hlist_nulls_unhashed(&tw->tw_node))
>> +		return;
>> +
>> +	hlist_nulls_del_rcu(&tw->tw_node);
>> +	sk_nulls_node_init(&tw->tw_node);
>> +	inet_twsk_put(tw);
>=20
> Is it safe to call in locked context? inet_twsk_put() schedules
> preemption, also I did not check what tw destructor does.
>=20

You are probably right, we could defer the inet_twsk_put(tw) out of loc=
ked
section, you or I will submit another patch to correct this.

Thanks !
