From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: Fix lockdep warning on est_tree_lock in
 gen_estimator
Date: Thu, 2 Sep 2010 23:22:45 +0200
Message-ID: <20100902212245.GA5210@del.dom.local>
References: <20100902201257.GA3089@del.dom.local>
 <1283460813.3699.243.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:45459 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757819Ab0IBVWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 17:22:51 -0400
Received: by wyb35 with SMTP id 35so175236wyb.19
        for <netdev@vger.kernel.org>; Thu, 02 Sep 2010 14:22:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1283460813.3699.243.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 02, 2010 at 10:53:33PM +0200, Eric Dumazet wrote:
> Le jeudi 02 septembre 2010 ?? 22:12 +0200, Jarek Poplawski a =E9crit =
:
> > @@ -270,7 +270,7 @@ void gen_kill_estimator(struct gnet_stats_basic=
_packed *bstats,
> >  {
> >  	struct gen_estimator *e;
> > =20
> > -	spin_lock(&est_tree_lock);
> > +	spin_lock_bh(&est_tree_lock);
> >  	while ((e =3D gen_find_node(bstats, rate_est))) {
> >  		rb_erase(&e->node, &est_root);
> > =20
>=20
> If you lock bh for est_tree_lock(), we dont need _bh for est_lock her=
e

Right. But since the patch was merged and it's not crucial, I guess
you could send a separate patch?

Thanks,
Jarek P.=20
