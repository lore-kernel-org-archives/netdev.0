From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch] mac80211: potential null dereference in mesh forwarding
Date: Mon, 03 Jan 2011 08:45:38 +0100
Message-ID: <1294040738.2535.265.camel@edumazet-laptop>
References: <20110103054355.GP1886@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:51431 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751961Ab1ACHpt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jan 2011 02:45:49 -0500
In-Reply-To: <20110103054355.GP1886@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 03 janvier 2011 =C3=A0 08:43 +0300, Dan Carpenter a =C3=A9crit=
 :
> The printk() is supposed to be ratelimited but we should always goto =
out
> when fwd_skb is NULL.  Otherwise it gets dereferenced on the next lin=
e.
>=20
> Signed-off-by: Dan Carpenter <error27@gmail.com>
>=20
> diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
> index 5e9d3bc..dc8b566 100644
> --- a/net/mac80211/rx.c
> +++ b/net/mac80211/rx.c
> @@ -1831,8 +1831,9 @@ ieee80211_rx_h_mesh_fwding(struct ieee80211_rx_=
data *rx)
> =20
>  			fwd_skb =3D skb_copy(skb, GFP_ATOMIC);
> =20
> -			if (!fwd_skb && net_ratelimit()) {
> -				printk(KERN_DEBUG "%s: failed to clone mesh frame\n",
> +			if (!fwd_skb) {
> +				if (net_ratelimit())
> +					printk(KERN_DEBUG "%s: failed to clone mesh frame\n",
>  						   sdata->name);
>  				goto out;
>  			}

Already discovered/coped by Milton Miller.



