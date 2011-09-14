From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: don't clear IFF_XMIT_DST_RELEASE in ether_setup
Date: Wed, 14 Sep 2011 15:28:41 +0200
Message-ID: <1316006922.2361.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1316005502-7341-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Pekka Riikonen <priikone@iki.fi>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:58244 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932610Ab1INN2k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2011 09:28:40 -0400
Received: by bkbzt4 with SMTP id zt4so1540592bkb.19
        for <netdev@vger.kernel.org>; Wed, 14 Sep 2011 06:28:38 -0700 (PDT)
In-Reply-To: <1316005502-7341-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 14 septembre 2011 =C3=A0 09:05 -0400, Neil Horman a =C3=A9c=
rit :
> d88733150 introduced the IFF_SKB_TX_SHARING flag, which I unilaterall=
y set in
> ether_setup.  In doing this I didn't realize that other flags (such a=
s
> IFF_XMIT_DST_RELEASE) might be set prior to calling the ether_setup r=
outine.
> This patch changes ether_setup to or in SKB_TX_SHARING so as not to
> inadvertently clear other existing flags.  Thanks to Pekka Riikonen f=
or pointing
> out my error
>=20
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> Reported-by: Pekka Riikonen <priikone@iki.fi>
> CC: "David S. Miller" <davem@davemloft.net>
> ---
>  net/ethernet/eth.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
> index 27997d3..a246836 100644
> --- a/net/ethernet/eth.c
> +++ b/net/ethernet/eth.c
> @@ -340,7 +340,7 @@ void ether_setup(struct net_device *dev)
>  	dev->addr_len		=3D ETH_ALEN;
>  	dev->tx_queue_len	=3D 1000;	/* Ethernet wants good queues */
>  	dev->flags		=3D IFF_BROADCAST|IFF_MULTICAST;
> -	dev->priv_flags		=3D IFF_TX_SKB_SHARING;
> +	dev->priv_flags		|=3D IFF_TX_SKB_SHARING;
> =20
>  	memset(dev->broadcast, 0xFF, ETH_ALEN);
> =20

I CC Pekka Riikonen <priikone@iki.fi>, not sure if he is netdev
subscribded.

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
