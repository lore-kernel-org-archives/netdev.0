From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/6] netfilter: ctnetlink: use GFP_ATOMIC in all
 allocations
Date: Tue, 06 Mar 2012 07:09:17 -0800
Message-ID: <1331046557.2474.45.camel@edumazet-laptop>
References: <1331032975-5303-1-git-send-email-pablo@netfilter.org>
	 <1331032975-5303-4-git-send-email-pablo@netfilter.org>
	 <1331038221.9504.9.camel@edumazet-glaptop> <20120306144838.GA1527@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120306144838.GA1527@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 06 mars 2012 =C3=A0 15:48 +0100, Pablo Neira Ayuso a =C3=A9cri=
t :
> On Tue, Mar 06, 2012 at 04:50:21AM -0800, Eric Dumazet wrote:

> > This cant be right.
> >=20
> > Really this must be kept as GFP_KERNEL allocations.
> >=20
> > Only if .call_rcu member is used in place of .call rcu_read_lock() =
is
> > held instead of nfnl_lock().
>=20
> I thought we couldn't sleep while holding rcu_read_lock.

True, but as far as I can see we dont hold rcu_read_lock() at this
point, only a mutex.

I added the .call_rcu() mechanism in struct nfnl_callback only for very
specific needs, namely performance improvements in commit 84a797dd0
(netfilter: nfnetlink_queue: provide rcu enabled callbacks)



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
