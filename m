From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [rfc] IPVS: convert scheduler management to RCU
Date: Fri, 20 Aug 2010 16:32:45 +0200
Message-ID: <1282314765.2484.104.camel@edumazet-laptop>
References: <20100820133320.GA29311@verge.net.au>
	 <AANLkTimS7V3z1kEwmEFCCvPzJX=D9Oqw=BNEuN-YZ0tx@mail.gmail.com>
	 <1282313150.2484.65.camel@edumazet-laptop>
	 <AANLkTi=t7wDZO23Cim1LJ_Ot2FUe4bR+XG6H5uJfTuG+@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>, Simon Horman <horms@verge.net.au>,
	lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Wensong Zhang <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>,
	Paul E McKenney <paulmck@linux.vnet.ibm.com>
To: yao zhao <dragonlinux@gmail.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <AANLkTi=t7wDZO23Cim1LJ_Ot2FUe4bR+XG6H5uJfTuG+@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 20 ao=C3=BBt 2010 =C3=A0 10:16 -0400, yao zhao a =C3=A9crit=
 :

> if it is not performance critical, you should use  the
> read_lock/write_lock, it should make the readers happier than
> spinlock. the name "mutex" is a little bit confuse.

Yes, I mentioned the 'mutex' name oddity.

Point is :

We want to remove read_write locks. They dont fit the bill.

If performance critical, lot of readers -> RCU (a lot faster)
If not, or too much writers versus readers -> spinlock (a bit faster)



> synchronize_rcu() is not necessary when you only need to delete from =
a
> list as it is atomic.
>=20

Thats a rather strange and completely wrong claim. A big part of RCU jo=
b
is to have appropriate work done on deletes. Inserts are more easy (onl=
y
needs a smp_wmb())

Take a look at Documentation/RCU/* before saying such things ;)

Not only synchronize_rcu() is not enough to protect this kind of code,
but you need something stronger.


