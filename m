From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] e1000e: convert to stats64
Date: Thu, 16 Dec 2010 13:50:30 +0100
Message-ID: <1292503830.2883.92.camel@edumazet-laptop>
References: <1292358735-32089-1-git-send-email-fleitner@redhat.com>
	 <1292362173.2478.6.camel@edumazet-laptop>
	 <20101216123131.GA3070@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Flavio Leitner <fleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:52785 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753320Ab0LPMuf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 07:50:35 -0500
Received: by wwa36 with SMTP id 36so2387763wwa.1
        for <netdev@vger.kernel.org>; Thu, 16 Dec 2010 04:50:34 -0800 (PST)
In-Reply-To: <20101216123131.GA3070@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 16 d=C3=A9cembre 2010 =C3=A0 10:31 -0200, Flavio Leitner a =C3=
=A9crit :

> -static struct net_device_stats *e1000_get_stats(struct net_device *n=
etdev)
> +struct rtnl_link_stats64 *e1000e_get_stats64(struct net_device *netd=
ev,
> +						   struct rtnl_link_stats64 *stats)
>  {
> -	/* only return the current stats */
> -	return &netdev->stats;
> +	struct e1000_adapter *adapter =3D netdev_priv(netdev);
> +
> +	memset(stats, 0, sizeof(struct rtnl_link_stats64));

You dont need this memset(), stats is cleared by caller (dev_get_stats(=
)
in net/core/dev.c), as this was always done ;)

> +	spin_lock(&adapter->stats64_lock);
> +	e1000e_update_stats(adapter);
> +	/* Fill out the OS statistics structure */
> +	stats->rx_bytes =3D adapter->stats.gorc;
> +	stats->rx_packets =3D adapter->stats.gprc;
> +	stats->tx_bytes =3D adapter->stats.gotc;
> +	stats->tx_packets =3D adapter->stats.gptc;
> +	stats->multicast =3D adapter->stats.mprc;
> +	stats->collisions =3D adapter->stats.colc;
> +

