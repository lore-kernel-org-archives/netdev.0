From: Mark Brown <broonie@kernel.org>
Subject: linux-next: net/sched/cls_flower.c
Date: Tue, 17 Oct 2017 11:15:09 +0100
Message-ID: <20171017101509.soy55d4ipx3dusbo@sirena.co.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="r45awaaj4t2izqjs"
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>, Jiri Pirko <jiri@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--r45awaaj4t2izqjs
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net-next tree, today's linux-next build
(x86_allmodconfig) failed like this:

/home/broonie/tmpfs/next/net/sched/cls_flower.c: In function 'fl_hw_destroy=
_filter':
/home/broonie/tmpfs/next/net/sched/cls_flower.c:208:12: error: 'struct tc_c=
ls_flower_offload' has no member named 'egress_dev'
  cls_flower.egress_dev =3D f->hw_dev !=3D tp->q->dev_queue->dev;
            ^
/home/broonie/tmpfs/next/net/sched/cls_flower.c:208:27: error: 'struct cls_=
fl_filter' has no member named 'hw_dev'
  cls_flower.egress_dev =3D f->hw_dev !=3D tp->q->dev_queue->dev;
                           ^
/home/broonie/tmpfs/next/net/sched/cls_flower.c: In function 'fl_hw_update_=
stats':
/home/broonie/tmpfs/next/net/sched/cls_flower.c:270:12: error: 'struct tc_c=
ls_flower_offload' has no member named 'egress_dev'
  cls_flower.egress_dev =3D f->hw_dev !=3D tp->q->dev_queue->dev;
            ^
/home/broonie/tmpfs/next/net/sched/cls_flower.c:270:27: error: 'struct cls_=
fl_filter' has no member named 'hw_dev'
  cls_flower.egress_dev =3D f->hw_dev !=3D tp->q->dev_queue->dev;
                           ^
/home/broonie/tmpfs/next/scripts/Makefile.build:319: recipe for target 'net=
/sched/cls_flower.o' failed

Caused by commit

  7578d7b45ed870b13a8ace57e32feaed623c2a94 ("net/sched: cls_flower: Set egr=
ess_dev mark when calling into the HW driver")

interacting with=20

  7578d7b45ed870b1 ("net: sched: remove unused tcf_exts_get_dev helper and =
cls_flower->egress_dev")

both in the net-next tree.  Falling back to previous net-next trees
introduced other issues so I reverted that commit for today.

--r45awaaj4t2izqjs
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEreZoqmdXGLWf4p/qJNaLcl1Uh9AFAlnl2CwACgkQJNaLcl1U
h9CDMAf9HgFu4TLIQYMwAa7CaAaS/vkXoQuBv7DYsslRodSAKlGv6iSYDWISqU6W
uorSBVd0PU25nVp+bx8fCLBVA61RUIN5D/1MD/nnlV/6w2BipQ6l6AgYlto1A8Ll
P5WpFwTW6abxa/2O2WYsyic5AKDYDfItuDWEb3kvJSlZtWxbr/ynqTppaqkkAIaC
DsEpKVVX0jBKsuuRy1A1hFYD9/EFAyI1x9vxOwUq02HYl1tuw2b63Ddh2QNywMRI
sXEKytHUbS02wHRwQ1d2kW+w22N0AqviegxtbbbevItV3yFRKaMQz3JKprwPzeVZ
bptbAjPFPZDQrtH2LhGxnYBpTyOqwg==
=Aa99
-----END PGP SIGNATURE-----

--r45awaaj4t2izqjs--
