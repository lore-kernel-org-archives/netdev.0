From: Felix Palmen <fmp@palmen.homeip.net>
Subject: Re: Fw: unregister_netdevice(): negative refcnt, suggest patch against 2.6.11
Date: Sun, 10 Apr 2005 23:27:27 +0200
Message-ID: <20050410212727.GA13829@palmen.homeip.net>
References: <20050410034446.39e3025e.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="wac7ysb48OaltWcw"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050410034446.39e3025e.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--wac7ysb48OaltWcw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

* Felix M. Palmen <fmp@palmen.homeip.net> [20050410 11:16]:
> So I assume there is a problem in the appletalk code, but I didn't try
> reproducing that on other systems so far.

I've now tested this issue on a vanilla 2.6.11.7 kernel. I only applied
my own patch from the previous post so that I am able to shut down the
computer cleanly. So I did the following:

- boot 2.6.11.7
- create a tap device with 'openvpn --mktun --dev tap0'
- create /etc/netatalk/atalkd.conf with a single line 'tap0'
- launch atalkd, wait.
- stop atalkd.
- destroy tap device with 'openvpn --rmtun --dev tap0'

refcnt was -256, very strange.

Would you consider my patch harmful? I intend using it for now, because
otherwise, my system won't shut down cleanly any more...

Greets, Felix

PS: Please CC replies to me.
PPS: I'm sorry for the multipost (lkml and here), at first I didn't
realize Andrew was directing this thread to linux-netdev

--=20
 | /"\   ASCII Ribbon   | Felix M. Palmen (Zirias)    http://zirias.ath.cx/=
 |
 | \ / Campaign Against | fmp@palmen.homeip.net      encrypted mail welcome=
 |
 |  X    HTML In Mail   | PGP key: http://zirias.ath.cx/pub.txt            =
 |
 | / \     And News     | ED9B 62D0 BE39 32F9 2488 5D0C 8177 9D80 5ECF F683=
 |

--wac7ysb48OaltWcw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iQCVAwUBQlmaPwSq+3gxG9cNAQIjhAQAkmq9/KH9O76j5nQef9FDnXLdF6bTr7sI
lMDBqTe6VVC6bUpFzbXbWUz8AHUkcQRxD5UIccUAnRb6eS99ME/VIQ2tyifMxowj
5ePIY5EAPpYukkk9tX0TxUcFHLs+3ks0OqgXFJaZktpJrrchusMvim9daEWdhglq
H5mhWeRZRmY=
=WPAX
-----END PGP SIGNATURE-----

--wac7ysb48OaltWcw--
