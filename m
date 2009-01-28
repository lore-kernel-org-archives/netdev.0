From: Patrick McHardy <kaber@trash.net>
Subject: Re: 32 core net-next stack/netfilter "scaling"
Date: Wed, 28 Jan 2009 17:25:44 +0100
Message-ID: <49808708.3050502@trash.net>
References: <497E361B.30909@hp.com>	<497E42F4.7080201@cosmosbay.com>	<497E44F6.2010703@hp.com>	<497ECF84.1030308@cosmosbay.com>	<497ED0A2.6050707@trash.net>	<497F350A.9020509@cosmosbay.com>	<497F457F.2050802@trash.net> <497F4C2F.9000804@hp.com> <497F5BCD.9060807@hp.com> <497F5F86.9010101@hp.com> <498063E7.5030106@cosmosbay.com>
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
In-Reply-To: <498063E7.5030106@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Rick Jones a =E9crit :
>> Anyhow, the spread on trans/s/netperf is now 600 to 500 or 6000, whi=
ch
>> does represent an improvement.
>>
>=20
> Yes indeed you have a speedup, tcp conntracking is OK.
>=20
> You now hit the nf_conntrack_lock spinlock we have in generic conntra=
ck code=20
> (net/netfilter/nf_conntrack_core.c)
>=20
> nf_ct_refresh_acct() for instance has to lock it.
>=20
> We really want some finer locking here.

That looks more complicated since it requires to take multiple locks
occasionally (f.i. hash insertion, potentially helper-related and
expectation-related stuff), and there is the unconfirmed_list, where
fine-grained locking can't really be used without changing it to
a hash.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
