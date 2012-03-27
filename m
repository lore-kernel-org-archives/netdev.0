From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] eql: Fix byte stats
Date: Tue, 27 Mar 2012 01:12:45 -0700
Message-ID: <1332835965.3248.2.camel@edumazet-laptop>
References: <1332669700.32446.142.camel@shinybook.infradead.org>
	 <1332746975.2379.5.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:57915 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754049Ab2C0IMv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 04:12:51 -0400
Received: by wejx9 with SMTP id x9so4737907wej.19
        for <netdev@vger.kernel.org>; Tue, 27 Mar 2012 01:12:49 -0700 (PDT)
In-Reply-To: <1332746975.2379.5.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 26 mars 2012 =C3=A0 08:29 +0100, David Woodhouse a =C3=A9crit =
:

Missing changelog and "Signed-off-by: ..."

> ---
> Sorry, forgot to tell Evolution not to word-wrap last time. It's a
> manual process =E2=80=94 insert the patch from a text file, and set i=
t to
> 'Preformatted'. I've also disabled the signature on this version; I'm
> not entirely sure if the git-am bug with QP got fixed yet.
>=20

I use Evolution too, its not that bad :)

> diff --git a/drivers/net/eql.c b/drivers/net/eql.c
> index a59cf96..f2d3741 100644
> --- a/drivers/net/eql.c
> +++ b/drivers/net/eql.c
> @@ -345,6 +345,7 @@ static netdev_tx_t eql_slave_xmit(struct sk_buff =
*skb, struct net_device *dev)
>  		slave->bytes_queued +=3D skb->len;
>  		dev_queue_xmit(skb);
>  		dev->stats.tx_packets++;
> +		dev->stats.tx_bytes +=3D skb->len;
>  	} else {
>  		dev->stats.tx_dropped++;
>  		dev_kfree_skb(skb);
>=20

That adds a bug unfortunately.

After dev_queue_xmit(skb) call, you cant safely dereference skb anymore=
=2E
