From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH]  bridge: per-cpu packet statistics
Date: Tue, 02 Mar 2010 08:51:42 +0100
Message-ID: <1267516302.2843.12.camel@edumazet-laptop>
References: <20100301161658.5a61143b@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:35859 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753408Ab0CBHvs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Mar 2010 02:51:48 -0500
Received: by bwz1 with SMTP id 1so874518bwz.21
        for <netdev@vger.kernel.org>; Mon, 01 Mar 2010 23:51:46 -0800 (PST)
In-Reply-To: <20100301161658.5a61143b@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 01 mars 2010 =C3=A0 16:16 -0800, Stephen Hemminger a =C3=A9cri=
t :
> --- a/net/bridge/br_if.c	2010-03-01 08:22:23.476657998 -0800
> +++ b/net/bridge/br_if.c	2010-03-01 15:30:47.733227819 -0800
> @@ -185,6 +185,12 @@ static struct net_device *new_bridge_dev
>  	br =3D netdev_priv(dev);
>  	br->dev =3D dev;
> =20
> +	br->stats =3D alloc_percpu(sizeof(struct br_cpu_netstats));
> +	if (!br->stats) {
> +		free_netdev(dev);
> +		return NULL;
> +	}
> +

Strange... this should be :

	nr->stats =3D alloc_percpu(struct br_cpu_netstats);

Or even better, ask percpu allocator an aligned chunk=20
(2 or 4 longs) instead of (1 long)

	nr->stats =3D __alloc_percpu(sizeof(struct br_cpu_netstats),
				   4 * sizeof(long));


