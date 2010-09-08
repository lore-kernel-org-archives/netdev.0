From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] lockdep warning in gen_kill_estimator
Date: Wed, 08 Sep 2010 21:23:03 +0200
Message-ID: <1283973783.2428.11.camel@edumazet-laptop>
References: <20100908112719.3f4b4644@nehalam>
	 <1283971234.2428.4.camel@edumazet-laptop> <20100908121628.0eee5294@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:58944 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753160Ab0IHTXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 15:23:12 -0400
Received: by fxm16 with SMTP id 16so378663fxm.19
        for <netdev@vger.kernel.org>; Wed, 08 Sep 2010 12:23:10 -0700 (PDT)
In-Reply-To: <20100908121628.0eee5294@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 08 septembre 2010 =C3=A0 12:16 -0700, Stephen Hemminger a =C3=
=A9crit :

> But that commit adds unnecessary bh_disable
> -------

Yes I mentioned it in the original patch discussion


> Subject: [PATCH] pkt_sched: remov unnecessary bh_disable
>=20
> Now that est_tree_lock is acquired with BH protection, the other
> call is unnecessary.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
> --- a/net/core/gen_estimator.c	2010-09-08 12:13:55.182851300 -0700
> +++ b/net/core/gen_estimator.c	2010-09-08 12:14:07.401063663 -0700
> @@ -274,9 +274,9 @@ void gen_kill_estimator(struct gnet_stat
>  	while ((e =3D gen_find_node(bstats, rate_est))) {
>  		rb_erase(&e->node, &est_root);
> =20
> -		write_lock_bh(&est_lock);
> +		write_lock(&est_lock);
>  		e->bstats =3D NULL;
> -		write_unlock_bh(&est_lock);
> +		write_unlock(&est_lock);
> =20
>  		list_del_rcu(&e->list);
>  		call_rcu(&e->e_rcu, __gen_kill_estimator);
>=20
>=20
>=20


