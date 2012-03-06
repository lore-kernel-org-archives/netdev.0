From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 3/6] netfilter: ctnetlink: use GFP_ATOMIC in all
 allocations
Date: Tue, 6 Mar 2012 16:35:13 +0100
Message-ID: <20120306153513.GA1725@1984>
References: <1331032975-5303-1-git-send-email-pablo@netfilter.org>
 <1331032975-5303-4-git-send-email-pablo@netfilter.org>
 <1331038221.9504.9.camel@edumazet-glaptop>
 <20120306144838.GA1527@1984>
 <1331046557.2474.45.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:37608 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965153Ab2CFPfS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2012 10:35:18 -0500
Content-Disposition: inline
In-Reply-To: <1331046557.2474.45.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 06, 2012 at 07:09:17AM -0800, Eric Dumazet wrote:
> Le mardi 06 mars 2012 =E0 15:48 +0100, Pablo Neira Ayuso a =E9crit :
> > On Tue, Mar 06, 2012 at 04:50:21AM -0800, Eric Dumazet wrote:
>=20
> > > This cant be right.
> > >=20
> > > Really this must be kept as GFP_KERNEL allocations.
> > >=20
> > > Only if .call_rcu member is used in place of .call rcu_read_lock(=
) is
> > > held instead of nfnl_lock().
> >=20
> > I thought we couldn't sleep while holding rcu_read_lock.
>=20
> True, but as far as I can see we dont hold rcu_read_lock() at this
> point, only a mutex.
>=20
> I added the .call_rcu() mechanism in struct nfnl_callback only for ve=
ry
> specific needs, namely performance improvements in commit 84a797dd0
> (netfilter: nfnetlink_queue: provide rcu enabled callbacks)

Sorry, I overlooked that changed, I still thought that we were calling
these under rcu_read_lock.

This patch has to be kept out indeed. Thanks for spotting this Eric.
