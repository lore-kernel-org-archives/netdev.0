From: Wolfram Sang <w.sang@pengutronix.de>
Subject: Re: Phylib polling when doing mdio_read will cause system response
	and transfer speed drop
Date: Mon, 19 Apr 2010 09:21:21 +0200
Message-ID: <20100419072121.GA15697@pengutronix.de>
References: <4BC50BF5.7080700@canonical.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="tThc/1wpZn/ma/RB"
Cc: afleming@freescale.com, davem@davemloft.net,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Bryan Wu <bryan.wu@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4BC50BF5.7080700@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--tThc/1wpZn/ma/RB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Apr 13, 2010 at 05:27:33PM -0700, Bryan Wu wrote:

> I found the root cause is the polling operation in the mdio_read=20
> function. When we transfer large files, we experienced many times of=20
> timeout issue. So I got several question here:

Same here, I saw the 'MDIO Timeout' Message occasionally.

> 1. Need I return -ETIMEDOUT when polling timeout. If I don't return=20
> -ETIMEOUT, the performance improved a lot. And after check other drivers,=
=20
> some don't return anything, some return 0, some return negative value.=20
> What's the rule for this mdio_read polling timeout case.
>
> 2. How to do polling busy waiting? Normally, we won't buys wait very long=
=20
> in polling. But hardware is not perfect every time. Running cpu_relax()=
=20
> 10000 times in polling will cause our system response very bad when=20
> hardware don't set the flag as we expected. Maybe udelay(25) 10 times or=
=20
> msleep(1) 10 times is better than that.
>
> I got a patch to recover this issue, =20
> http://kernel.ubuntu.com/git?p=3Droc/ubuntu-lucid.git;a=3Dcommitdiff;h=3D=
5d77e3409b319ca84183bf1d2fd158a9c864e03f.

Can't help with the details, but the patch seems to help here, too
(and not only because of the removed printk ;)).

Regards,

   Wolfram

--=20
Pengutronix e.K.                           | Wolfram Sang                |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--tThc/1wpZn/ma/RB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkvMBHEACgkQD27XaX1/VRvozgCfa2IevtCOomaSfQeezLZIpScN
WGsAni3BRDAwKVNgih/GVkKE3igqgrLw
=f849
-----END PGP SIGNATURE-----

--tThc/1wpZn/ma/RB--
