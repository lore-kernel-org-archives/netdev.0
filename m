From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] snmp6 relevant data structures are freed twice.
Date: Mon, 19 Sep 2011 10:29:49 +0200
Message-ID: <1316420989.2539.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1316415793-2711-1-git-send-email-rongqing.li@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: rongqing.li@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:49449 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752739Ab1ISI3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2011 04:29:40 -0400
Received: by bkbzt4 with SMTP id zt4so5107761bkb.19
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2011 01:29:39 -0700 (PDT)
In-Reply-To: <1316415793-2711-1-git-send-email-rongqing.li@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 19 septembre 2011 =C3=A0 15:03 +0800, rongqing.li@windriver.co=
m a
=C3=A9crit :
> From: Roy.Li <rongqing.li@windriver.com>
>=20
> When calling snmp6_alloc_dev fails, the snmp6 relevant memory
> are freed by snmp6_alloc_dev. Calling in6_dev_finish_destroy
> will free these memory twice.
>=20
> Double free will lead that undefined behavior occurs.
>=20
> Signed-off-by: Roy.Li <rongqing.li@windriver.com>
> ---
>  net/ipv6/addrconf.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 8f1e5be..ba01f72 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -374,8 +374,8 @@ static struct inet6_dev * ipv6_add_dev(struct net=
_device *dev)
>  			"%s(): cannot allocate memory for statistics; dev=3D%s.\n",
>  			__func__, dev->name));
>  		neigh_parms_release(&nd_tbl, ndev->nd_parms);
> -		ndev->dead =3D 1;
> -		in6_dev_finish_destroy(ndev);
> +		dev_put(dev);
> +		kfree(ndev);
>  		return NULL;
>  	}
> =20

This seems a very old bug, and your fix applicable to old kernels as
well, thanks.

Could your patch title could be refined to the following ?

0) No need for the 1/1 suffix
1) include ipv6: prefix
2) change the message a bit, since normal operations are OK, only
failure and error recovery is buggy.

[PATCH] ipv6: fix a possible double free

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
