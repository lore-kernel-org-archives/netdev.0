From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] veth: delay peer link configuration after interfaces are
 tied
Date: Mon, 30 May 2016 11:23:35 +0200
Message-ID: <574C0697.6060506@6wind.com>
References: <1464520637-19784-1-git-send-email-vincent@bernat.im>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Vincent Bernat <vincent@bernat.im>,
	"David S. Miller" <davem@davemloft.net>,
	Vijay Pandurangan <vijayp@vijayp.ca>,
	Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:37908 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754141AbcE3JXj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 May 2016 05:23:39 -0400
Received: by mail-wm0-f46.google.com with SMTP id n129so63714580wmn.1
        for <netdev@vger.kernel.org>; Mon, 30 May 2016 02:23:39 -0700 (PDT)
In-Reply-To: <1464520637-19784-1-git-send-email-vincent@bernat.im>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 29/05/2016 13:17, Vincent Bernat a =C3=A9crit :
[snip]
> diff --git a/drivers/net/veth.c b/drivers/net/veth.c
> index f37a6e61d4ad..9726c4dbf659 100644
> --- a/drivers/net/veth.c
> +++ b/drivers/net/veth.c
> @@ -432,10 +432,6 @@ static int veth_newlink(struct net *src_net, str=
uct net_device *dev,
> =20
>  	netif_carrier_off(peer);
> =20
> -	err =3D rtnl_configure_link(peer, ifmp);
> -	if (err < 0)
> -		goto err_configure_peer;
> -
>  	/*
>  	 * register dev last
>  	 *
> @@ -466,6 +462,10 @@ static int veth_newlink(struct net *src_net, str=
uct net_device *dev,
> =20
>  	priv =3D netdev_priv(peer);
>  	rcu_assign_pointer(priv->peer, dev);
> +
> +	err =3D rtnl_configure_link(peer, ifmp);
> +	if (err < 0)
> +		goto err_configure_peer;
You should fix the error path. 'unregister_netdevice(dev)' is missing.
