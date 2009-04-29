From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Regression since 2.6.30-rc1 - Page allocation failures
Date: Thu, 30 Apr 2009 01:39:02 +0200
Message-ID: <1241048343.25477.7.camel@johannes.local>
References: <49F8C03D.6040909@lwfinger.net>
	 (sfid-20090429_230225_847074_E5413886)  <1241039372.4547.3.camel@johannes.local>
	 (sfid-20090429_231009_993152_4FF82E4D) <1241040451.5067.0.camel@johannes.local>
	 <49F8E145.1050708@lwfinger.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-kyK/pAUYx0XbStFT5uCy"
Cc: wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:42179 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751465AbZD2Xjc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 19:39:32 -0400
In-Reply-To: <49F8E145.1050708@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-kyK/pAUYx0XbStFT5uCy
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

(dropped lkml, added netdev)

> I get the "failed to reallocate TX buffer" message. Not all are related t=
o the
> page allocation failure. I am also getting "b43-phy0 debug: DMA RX:
> setup_rx_descbuffer() failed" messages.
>=20
> So far, the numbers printed by the revised printk are:
>=20
> kernel: phy0: failed to reallocate TX buffer 0, 404, need 0, 0
> kernel: protocol 0008 is buggy, dev eth1
>=20
> kernel: phy0: failed to reallocate TX buffer 0, 1728, need 0, 18
>=20
> Device eth1 is the b43 wireless device.

Thanks.

This is a little odd -- I don't see why
	pskb_expand_head(skb, 0, 0)
or
	pskb_expand_head(skb, 0, 18)

would try to do an order 1 allocation when skb->len is 404 or 1728. It
looks like something is forcing larger alignments than should be
necessary, but I have no idea what.

(for netdev: http://mid.gmane.org/49F8C03D.6040909@lwfinger.net has more
information)

johannes

--=-kyK/pAUYx0XbStFT5uCy
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJ+OUTAAoJEKVg1VMiehFY+ikP/2wAY9DzRMAxVjO6OvaAI4z9
uoGlLITnQ4d+cgZh3C6cJ/fR2nQxpCO1EuvEaIySHBFIGQXo4zoiuDIroXjqPqtf
NGfXDlRyEzGcCI7eSJmcEP+euc3II1whEOOaX71Ht8eFk2HG/Genyiv8YJJWT475
Q2Ynjhhl7mWYxpa3AJCavtb9DDP7JT8wfF1ENCySHGKa75+VRF7ED9O/VfBYeLxr
EBBcoapmXrfKs3vp2Z431XifMthbsf++HckMwTIK24ZWlxGxnF/bNtYP5264d2xT
uMZUl8UpeksuvrdZ5f+Hs3+MK41Hxn1KbaWGovftd3yy6c5emt/bATE1CJBYTAeV
wVmtW/mcyQQBz88w3ZmWGgBbfkc/OBWQdURcKzpnrBwONjuSasLf9Np7/EBSp24F
BgDRiVcYQGcnOHCF9kYE9YlaHEiR3v6uiRJx7kDAyEq8V3RT0tVKX+jj5xx/r+7U
7mE0F8sLwEJQNnyGPiVf4IyJjMO6c+bWeqWu3Ms3VSPvHxAetZRgcUWy8/L/L5J/
KQeQz7vD1TYJXSJrwoLr8XluqL/e7uq/68ynZbEGwyTrEfAXQIHRQkk2VQZkmF/W
YHBOaPxAocbNvgihhf+2TePFOr3FHzX/W0r62xuzULpc7I5XYWV624wKx8MmLSWc
Dbn6pHP0GsfFFJnDom6f
=1LYg
-----END PGP SIGNATURE-----

--=-kyK/pAUYx0XbStFT5uCy--

