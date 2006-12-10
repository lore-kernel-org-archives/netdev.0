From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] ieee80211softmac: Fix mutex_lock at exit of
	ieee80211_softmac_get_genie
Date: Sun, 10 Dec 2006 18:44:18 +0100
Message-ID: <1165772658.3131.34.camel@johannes.berg>
References: <20061210172701.GA29871@p15091797.pureserver.info>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-n3t5S+Peyp1/Z7w8aopB"
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Andrew Morton <akpm@osdl.org>, dsd@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:36015 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762285AbWLJRo2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Dec 2006 12:44:28 -0500
To: Ulrich Kunitz <kune@deine-taler.de>
In-Reply-To: <20061210172701.GA29871@p15091797.pureserver.info>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-n3t5S+Peyp1/Z7w8aopB
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2006-12-10 at 18:27 +0100, Ulrich Kunitz wrote:
> ieee80211softmac_wx_get_genie locks the associnfo mutex at
> function exit. This patch fixes it. The patch is against Linus'
> tree (commit af1713e0).

Looks good, I wonder how this slipped in.

Acked-by: Johannes Berg <johannes@sipsolutions.net>

> Signed-off-by: Ulrich Kunitz <kune@deine-taler.de>
> ---
>  net/ieee80211/softmac/ieee80211softmac_wx.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/ieee80211/softmac/ieee80211softmac_wx.c b/net/ieee80211/=
softmac/ieee80211softmac_wx.c
> index 480d72c..fa2f7da 100644
> --- a/net/ieee80211/softmac/ieee80211softmac_wx.c
> +++ b/net/ieee80211/softmac/ieee80211softmac_wx.c
> @@ -463,7 +463,7 @@ ieee80211softmac_wx_get_genie(struct net
>  			err =3D -E2BIG;
>  	}
>  	spin_unlock_irqrestore(&mac->lock, flags);
> -	mutex_lock(&mac->associnfo.mutex);
> +	mutex_unlock(&mac->associnfo.mutex);
> =20
>  	return err;
>  }

--=-n3t5S+Peyp1/Z7w8aopB
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFfEdx/ETPhpq3jKURAh/CAKCb+AiBDl/AjuAK2DnB16B7Hb04igCgt3I/
MXfDeGktpvI5sE2KHmbo4Oo=
=cOCU
-----END PGP SIGNATURE-----

--=-n3t5S+Peyp1/Z7w8aopB--

