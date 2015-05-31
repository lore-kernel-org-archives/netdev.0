From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] ethtool: changes of emac_regs structure accordingly
 within driver emac_regs structure.
Date: Sun, 31 May 2015 21:57:27 +0100
Message-ID: <1433105847.6319.139.camel@decadent.org.uk>
References: <20150521190917.6971eb09@fr-ThinkPad-W520>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-qLfSjaRUPZc4xNz6cIR/"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Ivan Mikhaylov <ivan@ru.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:58702 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751142AbbEaU5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 May 2015 16:57:40 -0400
In-Reply-To: <20150521190917.6971eb09@fr-ThinkPad-W520>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-qLfSjaRUPZc4xNz6cIR/
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2015-05-21 at 19:09 +0400, Ivan Mikhaylov wrote:
> In ibm_emac.c in ethtool size of emac structure which passing through to =
driver
> is nailed down and not correlating with current emac_regs structure.
>=20
> Signed-off-by: Ivan Mikhaylov <ivan@ru.ibm.com>
[...]

This is not backward-compatible.  It ought to be possible to mix and
match old and new ethtool and driver, except for the EMAC4SYNC case
which has been broken up until now.

Using the new definition of struct emac_regs, I think the driver and
ethtool need to agree that the MAC register dump sizes are:

EMAC:      offsetof(struct emac_regs, u1)
EMAC4:     offsetof(struct emac_regs, u1.emac4) + sizeof(p->u1.emac4)
EMAC4SYNC: offsetof(struct emac_regs, u1.emac4sync) + sizeof(p->u1.emac4syn=
c)

Ben.

--=20
Ben Hutchings
Reality is just a crutch for people who can't handle science fiction.

--=-qLfSjaRUPZc4xNz6cIR/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVWt1vOe/yOyVhhEJAQr/aw//dG6yVLnzi37/8AE0aP+KrzhgZa2Od4Kz
R0XJXFWkia1/SB77KYsjJxebTut6kx2d3z1E4I16zpW/e+8oLU1kbFPmmhHCAg13
wUFIcv5I6ivXjGMKjBvMQK/v547HRWs2DkuBe42wIKKj/VX8/FKrxgd9QGEE06va
qnrzUHNbWwLYt48vp9wouGpqZ05XsyW5sDYgnFP/Vehp+0QZB3PHm5mK+rwMXg5x
m9jdZSjxHm/gf3c6CfXEUdWaBI15XTfGo88HDS2HgPZ0Ubp79ogOgdOqlSvU1+1U
7QU0+jX/vH+RQKE1eVad3rvw3BHK1QVN5cU2uqaNbgRz7w4Qd1ybcapStN3aFtMD
xGsjepHHC8DbRirigaag3T2nvkUyAX0gymLTrFxz18B3gn+rjrzD91AXp3R6auJe
QegpajzRxrGfq0yZ5bwQU97msV3OW2FqmJOxpnhSaV37T+D/jabPTdZTzyUeA9Nc
dlxwNwuIrNiGdVEkZTgET/XimhetGs6uC2Mt+tBtW3W34SSJCewtuhLrzAihun1X
5XC+iX2cW4KwIcGjpydhhwGbCmBYeoozJA9jrrg8mGhWjz7CRRPu+PYheRGKsbVV
ovVPAITfrohGqJtdP5hlMMdActoBvn7UYbmT3yKf0JZ0zYKxNWlTX/4JVKgY3pId
pd2rHrblfUk=
=seMG
-----END PGP SIGNATURE-----

--=-qLfSjaRUPZc4xNz6cIR/--
