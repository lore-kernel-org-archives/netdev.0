From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH]  bridge: per-cpu packet statistics
Date: Tue, 02 Mar 2010 08:43:52 +0100
Message-ID: <1267515832.2843.7.camel@edumazet-laptop>
References: <20100301161658.5a61143b@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:43001 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753408Ab0CBHn5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Mar 2010 02:43:57 -0500
Received: by bwz1 with SMTP id 1so870405bwz.21
        for <netdev@vger.kernel.org>; Mon, 01 Mar 2010 23:43:55 -0800 (PST)
In-Reply-To: <20100301161658.5a61143b@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 01 mars 2010 =C3=A0 16:16 -0800, Stephen Hemminger a =C3=A9cri=
t :
> +static void br_dev_free(struct net_device *dev)
> +{
> +	struct net_bridge *br =3D netdev_priv(dev);
> +
> +	free_percpu(br->stats);
> +}
> +
>  void br_dev_setup(struct net_device *dev)
>  {
>  	random_ether_addr(dev->dev_addr);
>  	ether_setup(dev);
> =20
>  	dev->netdev_ops =3D &br_netdev_ops;
> -	dev->destructor =3D free_netdev;
> +	dev->destructor =3D br_dev_free;
>  	SET_ETHTOOL_OPS(dev, &br_ethtool_ops);

Isnt free_netdev() missing after this change ?



