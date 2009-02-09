From: Patrick McHardy <kaber@trash.net>
Subject: Re: 32 core net-next stack/netfilter "scaling"
Date: Mon, 09 Feb 2009 15:57:05 +0100
Message-ID: <49904441.2090309@trash.net>
References: <497E361B.30909@hp.com>	<497E42F4.7080201@cosmosbay.com>	<497E44F6.2010703@hp.com>	<497ECF84.1030308@cosmosbay.com>	<497ED0A2.6050707@trash.net>	<497F350A.9020509@cosmosbay.com>	<497F457F.2050802@trash.net> <497F4C2F.9000804@hp.com> <497F5BCD.9060807@hp.com> <497F5F86.9010101@hp.com> <498063E7.5030106@cosmosbay.com> <49808708.3050502@trash.net> <498090C1.5020400@cosmosbay.com> <49809716.3020204@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rick Jones <rick.jones2@hp.com>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	Linux Network Development list <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <49809716.3020204@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Eric Dumazet a =E9crit :
>> Patrick McHardy a =E9crit :
>>> That looks more complicated since it requires to take multiple lock=
s
>>> occasionally (f.i. hash insertion, potentially helper-related and
>>> expectation-related stuff), and there is the unconfirmed_list, wher=
e
>>> fine-grained locking can't really be used without changing it to
>>> a hash.
>>>
>> Yes its more complicated, but look what we did in 2.6.29 for tcp/udp
>>  sockets, using RCU to have lockless lookups.
>> Yes, we still take a lock when doing an insert or delete at socket
>> bind/unbind time.
>>
>> We could keep a central nf_conntrack_lock to guard insertions/delete=
s
>> from hash and unconfirmed_list.
>>
>> But *normal* packets that only need to change state of one particula=
r
>> connection could use RCU (without spinlock) to locate the conntrack,
>> then lock the found conntrack to perform all state changes.
>=20
> Well... RCU is already used by conntrack :)
>=20
> Maybe only __nf_ct_refresh_acct() needs not taking nf_conntrack_lock

The lock is currently used to avoid timer update races.
Martin has two old patches two remove it, but they require
changes to the timer code to support a mod_timer variant
that doesn't enable an inactive timer:

http://people.netfilter.org/gandalf/performance/patches/mod_timer_noact
http://people.netfilter.org/gandalf/performance/patches/__nf_ct_refresh=
_acct-locking
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
