From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: tun: Use netif_receive_skb instead of netif_rx
Date: Thu, 20 May 2010 16:19:07 +1000
Message-ID: <20100520061907.GA8255@gondor.apana.org.au>
References: <20100519.195533.22536631.davem@davemloft.net> <20100520025741.GA6129@gondor.apana.org.au> <20100519.200522.140743640.davem@davemloft.net> <20100520033446.GA6434@gondor.apana.org.au> <1274332507.2658.31.camel@edumazet-laptop> <20100520052059.GC7443@gondor.apana.org.au> <1274333779.2658.43.camel@edumazet-laptop> <20100520054642.GA7836@gondor.apana.org.au> <1274335415.2658.46.camel@edumazet-laptop> <20100520061138.GA8183@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, bmb@athenacr.com,
	tgraf@redhat.com, nhorman@tuxdriver.com, nhorman@redhat.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:36416 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753777Ab0ETGTV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 May 2010 02:19:21 -0400
Content-Disposition: inline
In-Reply-To: <20100520061138.GA8183@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 20, 2010 at 04:11:38PM +1000, Herbert Xu wrote:
> On Thu, May 20, 2010 at 08:03:35AM +0200, Eric Dumazet wrote:
> > Le jeudi 20 mai 2010 =E0 15:46 +1000, Herbert Xu a =E9crit :
> >=20
> > > +#ifdef CONFIG_NET_CLS_CGROUP
> > > +static inline u32 task_cls_classid(struct task_struct *p)
> > > +{
> > > +	return container_of(task_subsys_state(p, net_cls_subsys_id),
> > > +			    struct cgroup_cls_state, css).classid;
> > > +}
> > > +#else
> > > +int net_cls_subsys_id =3D -1;
> > > +EXPORT_SYMBOL_GPL(net_cls_subsys_id);
> > > +
> > > +static inline u32 task_cls_classid(struct task_struct *p)
> > > +{
> > > +	int id;
> > > +	u32 classid;
> > > +
> > > +	rcu_read_lock();
> > > +	id =3D rcu_dereference(net_cls_subsys_id);
> > > +	if (id >=3D 0)
> > > +		classid =3D container_of(task_subsys_state(p, id),
> > > +				       struct cgroup_cls_state, css)->classid;
> > > +	rcu_read_unlock();
> > > +
> > > +	return classid;
> > > +}
> > > +#endif
> >=20
> > I still dont understand why you introduce this function and not reu=
se it
> > in net/sched/cls_cgroup.c
> >=20
> > You told me it needs a separate patch, I dont think so.
> > Just make it non static and EXPORTed
>=20
> Because it doesn't have to go through this RCU crap.

I'm talking about the rcu_dereference on net_cls_subsys_id of
course, not the rest of it.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
