From: Jan Kiszka <jan.kiszka@web.de>
Subject: Re: [PATCH] d80211: Fix inconsistent sta_lock usage
Date: Sat, 06 Jan 2007 17:33:28 +0100
Message-ID: <459FCF58.1060206@web.de>
References: <45996CBA.8020307@web.de> <a32f33a40701020730n773d7ed8pe99d98ecc7b96a0e@mail.gmail.com> <20070102162201.GA28457@infradead.org> <200701052108.40185.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigE4BD378467855CD8788EF9C4"
Cc: Jiri Benc <jbenc@suse.cz>, Christoph Hellwig <hch@infradead.org>,
	netdev@vger.kernel.org, rt2400-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate02.web.de ([217.72.192.227]:46634 "EHLO
	fmmailgate02.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751417AbXAFQdg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Jan 2007 11:33:36 -0500
To: Ivo van Doorn <ivdoorn@gmail.com>
In-Reply-To: <200701052108.40185.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigE4BD378467855CD8788EF9C4
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Ivo van Doorn wrote:
> +#define __bss_tim_set(__bss, __aid)	__set_bit((__aid), &(__bss)->tim)
> +

__set/clear_bit demands unsigned long, tim is u8. That causes quite some
warnings here.

=2E..
>  static inline void bss_tim_clear(struct ieee80211_local *local,
>  				 struct ieee80211_if_ap *bss, int aid)
>  {
>  	spin_lock(&local->sta_lock);
> -	bss->tim[(aid)/8] &=3D !(1<<((aid) % 8));
> +	__bss_tim_clear(bss, aid);
>  	spin_unlock(&local->sta_lock);

Probably forgotten: we need _bh here as well.

Jan


--------------enigE4BD378467855CD8788EF9C4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iD8DBQFFn89YniDOoMHTA+kRAvYYAJsFa9sTHFvYafocA1IupK6H6CMQowCfay/1
pCev2i7CUR+I7jois1LTlmE=
=URml
-----END PGP SIGNATURE-----

--------------enigE4BD378467855CD8788EF9C4--
