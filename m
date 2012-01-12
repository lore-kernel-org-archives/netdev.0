From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: conntrack, suspicious RCU usage
Date: Thu, 12 Jan 2012 03:35:40 +0100
Message-ID: <20120112023540.GC12255@1984>
References: <201201111025.50994.hans.schillstrom@ericsson.com>
 <1326276111.2767.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <201201111424.27282.hans.schillstrom@ericsson.com>
 <1326288835.2767.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1326293812.2767.37.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:38268 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751071Ab2ALCfm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jan 2012 21:35:42 -0500
Content-Disposition: inline
In-Reply-To: <1326293812.2767.37.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 11, 2012 at 03:56:52PM +0100, Eric Dumazet wrote:
> Le mercredi 11 janvier 2012 =E0 14:33 +0100, Eric Dumazet a =E9crit :
> > Le mercredi 11 janvier 2012 =E0 14:24 +0100, Hans Schillstrom a =E9=
crit :
> > > On Wednesday 11 January 2012 11:01:51 Eric Dumazet wrote:
> >=20
> > > > Hmm, we either need to take rcu_read_lock() while calling
> > > > __nf_ct_l3proto_find(), or define a variant using
> > > > rcu_dereference_protected() in places we hold nf_conntrack_lock
> > > >=20
> > > I made a qick test with locks /unlocks in
> > > __nf_ct_l3proto_find() and __nf_ct_l4proto_find()
> > >=20
> > > 	rcu_read_lock();
> > > ...
> > > 	rcu_read_unlock();
> > > 	return retp;
> > >=20
> > > It seems to help, I cant see the dump anymore and everything else=
 that I run works ...
> > >=20
> > >=20
> >=20
> > You cant do that, its just a brown paper bag :)
> >=20
> > If "retp" is returned, then the caller must handle the rcu_read_unl=
ock()
> > itself, after all possible "retp" dereferences.
> >=20
> > But really adding rcu_read_lock() should not be necessary on paths =
we
> > own the conntrack lock. We should use rcu_dereference_protected()
> > instead.
> >=20
>=20
> Well, __nf_ct_l4proto_find() being out of line and the way we already
> use rcu_read_lock() in this code, it seems following patch is
> the most natural way to cope with these lockdep warnings.
>=20
> Thanks
>=20
> [PATCH] netfilter: ctnetlink: fix lockep splats

Thanks Eric. I'll pass this to davem.
