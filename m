From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 2/2] e1000: fix possible reset_task running after
 adapter down
Date: Fri, 22 Nov 2013 15:14:01 -0800
Message-ID: <1385162041.2219.29.camel@jtkirshe-mobl>
References: <0555e8c422c9d920758399edfa08f72df9120713.1385107870.git.vdavydov@parallels.com>
	 <a0339f72560eeee5cad54c9363a5b5f196b83933.1385107870.git.vdavydov@parallels.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-qCkvmiVpjJKVnUIDPnxI"
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devel@openvz.org,
	Tushar Dave <tushar.n.dave@intel.com>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
To: Vladimir Davydov <vdavydov@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:27902 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755338Ab3KVXQq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Nov 2013 18:16:46 -0500
In-Reply-To: <a0339f72560eeee5cad54c9363a5b5f196b83933.1385107870.git.vdavydov@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-qCkvmiVpjJKVnUIDPnxI
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2013-11-22 at 12:20 +0400, Vladimir Davydov wrote:
> On e1000_down(), we should ensure every asynchronous work is canceled
> before proceeding. Since the watchdog_task can schedule other works
> apart from itself, it should be stopped first, but currently it is
> stopped after the reset_task. This can result in the following race
> leading to the reset_task running after the module unload:
>=20
> e1000_down_and_stop():                  e1000_watchdog():
> ----------------------                  -----------------
>=20
> cancel_work_sync(reset_task)
>                                         schedule_work(reset_task)
> cancel_delayed_work_sync(watchdog_task)
>=20
> The patch moves cancel_delayed_work_sync(watchdog_task) at the
> beginning
> of e1000_down_and_stop() thus ensuring the race is impossible.
>=20
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> Cc: Tushar Dave <tushar.n.dave@intel.com>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: David S. Miller <davem@davemloft.net>
> ---
>  drivers/net/ethernet/intel/e1000/e1000_main.c |   15 +++++++++++----
>  1 file changed, 11 insertions(+), 4 deletions(-)

I have applied your patch to my queue, thanks!

--=-qCkvmiVpjJKVnUIDPnxI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABCgAGBQJSj+U5AAoJEOVv75VaS+3OK58P/iqOzjKOE4sNDOZukDMyuDqR
4e96nEFc36Bzg8rEpD09DAvF7w+5KR0wu4596784ToqjFyz42CGfYsRDQXUAqa2N
OMW87D2gsbZb0fQMS4gUIOEL1oaWNAIqfW0M1cCiFcUqFdX7rGuSYf+O8r7CehCk
oNwEb77Q7Ld3M7p26MiUNR+cFGAz91q2FvG0NFgFPI8yndLrLz0flNurVZ78Ixeu
xVi8oV7M897qeISYZtZCx0n5WUCDZhpC865pz7hCH0cnc1/Hvm9ZpH1VdL+g1nAE
eUucqdEA9rqzveVlCQ6RVwua3utNiiiKrqNXYcloic8mOw+xWlKSeeVOb2kHvoa7
EtE8iEIad6xd8HxWkqCL41/SYqZdo4WGUF5KM7IpRvaAcyNt9CgULK29ox52xtlx
okNVYf43OwcvuZ4s+8gYaWECPV5AKmdovrWKlbHluO4dfFqxrHluZYigkdnLGeF9
4MrnJqx/H1V2NHfwfdAFi8uXE6BKAULd8NkMoV9Anv4CqA7fiI+a3+8Ksr0TRQRW
E957EnhXRUcQ5oVtiKdEy5GLlMfzpLF53mJTpRtW/+/aIJ0ZTUZGCvRsv6JE/2WH
P1p0vQZG/E/ymNm/7RyxxXvtZXOkC5z6RMdiDqmo19hjkMYfInNZhy9+fpnysFUf
3Z5uKJwz8MBr4PW7wu1T
=GiKe
-----END PGP SIGNATURE-----

--=-qCkvmiVpjJKVnUIDPnxI--
