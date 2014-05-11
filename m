From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] jme: Fix DMA unmap warning
Date: Sun, 11 May 2014 13:49:29 +0100
Message-ID: <1399812569.11946.131.camel@deadeye.wl.decadent.org.uk>
References: <1399315907-27148-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-OQ13X6cKYPUjdK+Nz9P2"
Cc: netdev@vger.kernel.org, Guo-Fu Tseng <cooldavid@cooldavid.org>,
	"David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:60286 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757245AbaEKMtm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 May 2014 08:49:42 -0400
In-Reply-To: <1399315907-27148-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-OQ13X6cKYPUjdK+Nz9P2
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-05-05 at 14:51 -0400, Neil Horman wrote:
[...]=20
> -static void
> +static void jme_drop_tx_map(struct jme_adapter *jme, int startidx, int e=
ndidx)
> +{
> +	struct jme_ring *txring =3D &(jme->txring[0]);
> +	struct jme_buffer_info *txbi =3D txring->bufinf, *ctxbi;
> +	int mask =3D jme->tx_ring_mask;
> +	int j;
> +
> +	for (j =3D startidx ; j < endidx ; ++j) {
> +		ctxbi =3D txbi + ((startidx + j + 2) & (mask));

So you're starting at startidx * 2 + 2, that can't be right.

[...]
> @@ -2228,7 +2268,8 @@ jme_start_xmit(struct sk_buff *skb, struct net_devi=
ce *netdev)
>  		return NETDEV_TX_BUSY;
>  	}
> =20
> -	jme_fill_tx_desc(jme, skb, idx);
> +	if (jme_fill_tx_desc(jme, skb, idx))
> +		return NETDEV_TX_BUSY;

NETDEV_TX_OK

Ben.

>  	jwrite32(jme, JME_TXCS, jme->reg_txcs |
>  				TXCS_SELECT_QUEUE0 |

--=20
Ben Hutchings
Sturgeon's Law: Ninety percent of everything is crap.

--=-OQ13X6cKYPUjdK+Nz9P2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUAU29x3ue/yOyVhhEJAQq0QQ/+JHNLblQJF7YZBUNCyi1NGgN+oE6IwUWK
QRCoQ4OBVlN7rhcBHE11dWBsLEqnOfu2nTdEJP//SdqflqF4H6PHdGiSLwSPthiX
i+zoAiexLho5qbqK+H9AoCwOE5eo4OkgjIX8MHRhi0i/h4DxSGD4BPHUanCymyiU
dKW73OrCdkqFgx9lagu4Ic5DGF/YYJcwp4gTuB1+rR4UdQYq3UyIKy7np4vQlmo3
p17dvHZn0mAskWYbVC9lb2G0vbhbQWoUsikQTCzW/wWT7beaqnokqpqOpQcbBmu8
T1shojv+qk/NnpO0fzOZyW3RujDv/VxiP1dHl2szYABHSB/wt3tjcxBT7x7vkJLM
C+m1U/2W8T7y7qGfQjv75F5zlr5XmFJtlewXOOLHveddr84CIPm6cx4gLzjgpxS6
FI//2Pnuv3v+d5vf0c4Lntg/8ecd0UHEwJao9nCHgU2553UU1gq4re3FLrXYWOZr
hGUIVikJr1qB7LrseIk2WwwuPu95CYLnIW5VnD/kNlbya8JadUSAwibHtJ/xM3Yh
v60EUMtSl6BTULXq6jyQUHfvl/cv08+ZvtwePKWigM2vPgyoKGqUdAF8pZm6/yn6
guGiERUEpEbW79KZ7T1WU2ac95019O6VZmBYeQfC7ubWkA9CEddPZPPjJ91mriE+
exgEaShlleU=
=/6zG
-----END PGP SIGNATURE-----

--=-OQ13X6cKYPUjdK+Nz9P2--
