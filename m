From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] net: kill an RCU warning in inet_fill_link_af()
Date: Mon, 06 Dec 2010 13:01:27 -0800 (PST)
Message-ID: <20101206.130127.179948200.davem@davemloft.net>
References: <1291202063-6239-1-git-send-email-amwang@redhat.com>
	<1291219386.2856.924.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: amwang@redhat.com, linux-kernel@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	tgraf@infradead.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1291219386.2856.924.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 01 Dec 2010 17:03:06 +0100

> Le mercredi 01 d=E9cembre 2010 =E0 19:14 +0800, Amerigo Wang a =E9cri=
t :
>> From: WANG Cong <amwang@redhat.com>
>>=20
>> The latest net-next-2.6 triggers an RCU warning during boot,
>> lockdep complains that in inet_fill_link_af() we call rcu_dereferenc=
e_check()
>> without rcu_read_lock() protection.
>>=20
>> This patch fixes it by replacing __in_dev_get_rcu() with in_dev_get(=
).
>=20
> Here is a better version, thanks a lot for your report and initial
> patch.
>=20
>=20
> [PATCH net-next-2.6] net: kill an RCU warning in inet_fill_link_af()
>=20
> commits 9f0f7272 (ipv4: AF_INET link address family) and cf7afbfeb8c
> (rtnl: make link af-specific updates atomic) used incorrect
> __in_dev_get_rcu() in RTNL protected contexts, triggering PROVE_RCU
> warnings.
>=20
> Switch to __in_dev_get_rtnl(), wich is more appropriate, since we hol=
d
> RTNL.
>=20
> Based on a report and initial patch from Amerigo Wang.
>=20
> Reported-by: Amerigo Wang <amwang@redhat.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Thomas Graf <tgraf@infradead.org>

Applied.
