From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] lockdep warning in gen_kill_estimator
Date: Wed, 08 Sep 2010 20:40:34 +0200
Message-ID: <1283971234.2428.4.camel@edumazet-laptop>
References: <20100908112719.3f4b4644@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:53282 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752122Ab0IHSki (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 14:40:38 -0400
Received: by fxm16 with SMTP id 16so340585fxm.19
        for <netdev@vger.kernel.org>; Wed, 08 Sep 2010 11:40:37 -0700 (PDT)
In-Reply-To: <20100908112719.3f4b4644@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 08 septembre 2010 =C3=A0 11:27 -0700, Stephen Hemminger a =C3=
=A9crit :
> Saw big lockdep SOFTIRQ-unsafe lock warning in gen_kill_estimator whe=
n doing.
>=20
>   tc qdisc del dev dummy0 root
>=20

>=20
> --- a/net/core/gen_estimator.c	2010-09-08 11:16:10.184368926 -0700
> +++ b/net/core/gen_estimator.c	2010-09-08 11:16:24.694194050 -0700
> @@ -270,18 +270,18 @@ void gen_kill_estimator(struct gnet_stat
>  {
>  	struct gen_estimator *e;
> =20
> -	spin_lock(&est_tree_lock);
> +	spin_lock_bh(&est_tree_lock);
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
>  	}
> -	spin_unlock(&est_tree_lock);
> +	spin_unlock_bh(&est_tree_lock);
>  }
>  EXPORT_SYMBOL(gen_kill_estimator);
> =20

Hmm... I think commit 0b5d404e349c0236
already takes care of this ?

Already in Linus tree=20



