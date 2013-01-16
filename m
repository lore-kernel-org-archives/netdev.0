From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: remove unneeded dirty_rx index
Date: Wed, 16 Jan 2013 16:25:00 -0500 (EST)
Message-ID: <20130116.162500.1216966272191204366.davem@davemloft.net>
References: <20130115225316.GA924@electric-eye.fr.zoreil.com>
	<1358319684-32364-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39408 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755763Ab3APVZC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 16:25:02 -0500
In-Reply-To: <1358319684-32364-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=E4s <timo.teras@iki.fi>
Date: Wed, 16 Jan 2013 09:01:24 +0200

> @@ -6035,10 +6034,8 @@ static int rtl_rx(struct net_device *dev, stru=
ct rtl8169_private *tp, u32 budget
>  	unsigned int count;
> =20
>  	cur_rx =3D tp->cur_rx;
> -	rx_left =3D NUM_RX_DESC + tp->dirty_rx - cur_rx;
> -	rx_left =3D min(rx_left, budget);
> =20
> -	for (; rx_left > 0; rx_left--, cur_rx++) {
> +	for (rx_left =3D min(budget, NUM_RX_DESC); rx_left > 0; rx_left--, =
cur_rx++) {

Is this really equivalent?  I think cur_rx still needs to be
incorporated into whatever you use as the initial rx_left.
