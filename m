From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [PATCH 1/1] ser_gigaset: use container_of() instead of detour
Date: Thu, 18 Feb 2016 22:42:15 +0100
Message-ID: <56C63AB7.9060401@imap.cc>
References: <1455827348-8574-1-git-send-email-pebolle@tiscali.nl>
 <1455827348-8574-2-git-send-email-pebolle@tiscali.nl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="8SknfINgPsWPJfUcXEVaq1H9iEJJt7e7L"
Cc: Dmitry Vyukov <dvyukov@google.com>,
	=?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <u.kleine-koenig@pengutronix.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Martin Wilck <Martin.Wilck@ts.fujitsu.com>,
	Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com>,
	linux-kernel@vger.kernel.org,
	gigaset307x-common@lists.sourceforge.net
To: Paul Bolle <pebolle@tiscali.nl>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:41821 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757255AbcBRVm3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 16:42:29 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id AE7FD20860
	for <netdev@vger.kernel.org>; Thu, 18 Feb 2016 16:42:28 -0500 (EST)
In-Reply-To: <1455827348-8574-2-git-send-email-pebolle@tiscali.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--8SknfINgPsWPJfUcXEVaq1H9iEJJt7e7L
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: quoted-printable

Am 18.02.2016 um 21:29 schrieb Paul Bolle:
> The purpose of gigaset_device_release() is to kfree() the struct
> ser_cardstate that contains our struct device. This is done via a bit o=
f
> a detour. First we make our struct device's driver_data point to the
> container of our struct ser_cardstate (which is a struct cardstate). In=

> gigaset_device_release() we then retrieve that driver_data again. And
> after that we finally kfree() the struct ser_cardstate that was saved i=
n
> the struct cardstate.
>=20
> All of this can be achieved much easier by using container_of() to get
> from our struct device to its container, struct ser_cardstate. Do so.

You're absolutely right. Very nice!

> Note that at the time the detour was implemented commit b8b2c7d845d5
> ("base/platform: assert that dev_pm_domain callbacks are called
> unconditionally") had just entered the tree. That commit disconnected
> our platform_device and our platform_driver. These were reconnected
> again in v4.5-rc2 through commit 25cad69f21f5 ("base/platform: Fix
> platform drivers with no probe callback"). And one of the consequences
> of that fix was that it broke the detour via driver_data. That's becaus=
e
> it made __device_release_driver() stop being a NOP for our struct devic=
e
> and actually do stuff again. One of the things it now does, is setting
> our driver_data to NULL. That, in turn, makes it impossible for
> gigaset_device_release() to get to our struct cardstate. Which has the
> net effect of leaking a struct ser_cardstate at every call of this
> driver's tty close() operation. So using container_of() has the
> additional benefit of actually working.
>=20
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Tested-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Paul Bolle <pebolle@tiscali.nl>

Acked-by: Tilman Schmidt <tilman@imap.cc>

Thanks for cleaning up the mess I left behind.

Tilman

--=20
Tilman Schmidt                              E-Mail: tilman@imap.cc
Bonn, Germany
Nous, on a des fleurs et des bougies pour nous prot=E9ger.


--8SknfINgPsWPJfUcXEVaq1H9iEJJt7e7L
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJWxjrBAAoJEFPuqx0v+F+q2m0H/RYEi0600xQFH5HGYa2ORTte
Ut/Ib4V1CT4GdDmHlRZn9AQ2LgQzW9Ek0m1tbNUSy5eRbkQcoErZ1omxR6b6O+zn
CaacONx9l3PDtwr+R0q1WRt1PHwAGtKZnH9Ou5yAVADGEnXg4GAbTZZk7XoKR4YB
aqB9I/axlTnu2853sm9OVzR2xTxucQYrciI+kP1oPM6vFe3SZlXJT7ewxnA5E2bY
f+hB0YRczGJCPPZZ+svtVxIOsISZeg0l0zev3GUC1dy6I62ZG2NiVpSYR4i+uSUT
oYOSgarWM071OIMH1BkAvkqtR0fRqCr6WKExfWkZkAIsteILYz1LmBtcnJhkLrA=
=UmQp
-----END PGP SIGNATURE-----

--8SknfINgPsWPJfUcXEVaq1H9iEJJt7e7L--
