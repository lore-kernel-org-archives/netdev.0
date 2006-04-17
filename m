From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH][RFC] softmac: suggest TX rate
Date: Mon, 17 Apr 2006 11:16:25 +0200
Message-ID: <1145265385.6560.48.camel@localhost>
References: <4442E13E.80507@gentoo.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-J4pxvWGgbLJ4Vz5sV9VU"
Cc: netdev@vger.kernel.org, softmac-dev@sipsolutions.net,
	Ulrich Kunitz <kune@deine-taler.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([213.151.39.204]:27110 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750719AbWDQJQ3
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Apr 2006 05:16:29 -0400
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <4442E13E.80507@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-J4pxvWGgbLJ4Vz5sV9VU
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2006-04-17 at 01:28 +0100, Daniel Drake wrote:

> Rather than having to explicitly call ieee80211softmac_suggest_tx_rate()=20
> from the driver's hard_start_xmit function, it would be nicer if the=20
> suggested rate was passed as a parameter. But not all drivers would need=20
> it, so maybe the extra calculations should be controlled by a new flag.

Couldn't we just initialise the softmac txrates substructure to
something useful when associating, and have drivers look into that
instead?

> +	case IEEE80211_FTYPE_DATA:
> +		if (unlikely(!mac->associated)) {
> +			dprintkl(KERN_ERROR PFX "suggest_tx_rate: Not associated\n");
> +			return IEEE80211_CCK_RATE_1MB;
> +		}
> +		return suggest_rate_from_associnfo(mac);

This isn't correct. Here, you have to take into account multicast frames
because those require clamping the rate to the highest rate from the
basic rateset.

I'll try to come up with an alternative.

johannes

--=-J4pxvWGgbLJ4Vz5sV9VU
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIVAwUARENc56Vg1VMiehFYAQISyBAApQJbajkxdDndgq+oOEewbozRQJurcdCT
14yG2Cb0k6YHxHIBmRjFGaD5T8cVz3alrw+MVYTkQKcJYRjOD/5yX8Cot0hnsP+h
qbLwBxo4YBgp5OV3z5sKzDqLdYH4UvpDvEQM6smrsUbZvgXYDTPNO0ntfLL5B5fE
EAPsfRyym4WaN749pkirAr5kOFH+9tR/QDY6DwjsarJ/MT8lmqgdwtjGqZ1CNjJb
Vism/E0QD4zG8QDB5VJNqw+gdt7HbgFbPiyggN6gS5xHzAuezAwLjRQJ0zvApALx
K1ZhcATTA3VBz6LrRfpKBVgI6xaBF+FHKQI/nivFUrLnrn6nQEDhAEyHMWIUXmBS
u+omXxe5moDx8Vtf0zgDkMsYkk4U3iFzDAOgUdlGNnzEWjP4WakwbmQNKL/rtfry
6TNweBxufsO2XOnaBV+tArARhIOoXOrSR3Kg7EPVqhMdjcNnjs6VQKQFLwV4p/fV
vx4pKQao12x0ZL2onKp/h6imZWyXpmnVaKFAykSFIVTj0bleco/yc186gSO7Dnik
qUicFun//LBAvBb2mV7ZpgntmW202wMWwdckhwxVzoCTcRkq8/qyzwi79XtuTUhP
hrRml3j6CCRT0BkeR2X82aYuennqOQwTT6D34fiexqtvgO24Wdp+vAWZKITJqcp6
jilddFLM8+Q=
=5Byk
-----END PGP SIGNATURE-----

--=-J4pxvWGgbLJ4Vz5sV9VU--

