From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [GIT] Networking
Date: Mon, 16 Aug 2010 10:48:59 +0000
Message-ID: <20100816104859.GA9178@ff.dom.local>
References: <20100816095325.GA8547@ff.dom.local> <1281955361.2524.35.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1281955361.2524.35.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 16, 2010 at 12:42:41PM +0200, Eric Dumazet wrote:
> Le lundi 16 ao??t 2010 ?? 09:53 +0000, Jarek Poplawski a =E9crit :
> > Eric Dumazet wrote:
> > > Le dimanche 15 aou^t 2010 a` 12:55 +0200, Eric Dumazet a =E9crit =
:
> > ...
> > > [PATCH] netfilter: {ip,ip6,arp}_tables: avoid lockdep false posit=
ive
> > >=20
> > > After commit 24b36f019 (netfilter: {ip,ip6,arp}_tables: dont bloc=
k
> > > bottom half more than necessary), lockdep can raise a warning
> > > because we attempt to lock a spinlock with BH enabled, while
> > > the same lock is usually locked by another cpu in a softirq conte=
xt.
> >=20
> > Btw, could you remind us how get_counters() are serialized (I guess
> > you can't have them on 2 cpus at the same time)?
> >=20
>=20
> get_counters() is serialized by the xt_find_table_lock() done from
> get_entries(). This use a mutex to guard against changes.
>=20
> You are right that if we ever allow two concurrent "iptables -nvL"
> operations in the future (using a read lock on a rwlock instead of a
> mutex), then we must disable BH even for summing data from the other
> cpus.

OK, thanks for the explanation,

Jarek P.
