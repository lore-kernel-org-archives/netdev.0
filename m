From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Wed, 30 Oct 2013 13:14:13 +1100
Message-ID: <20131030131413.51b3be1c0b0ac49b15eb6a5d@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__30_Oct_2013_13_14_13_+1100_M2eGa+aZxh.SWkwU"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Joe Perches <joe@perches.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__30_Oct_2013_13_14_13_+1100_M2eGa+aZxh.SWkwU
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/netconsole.c between commit c7c6effdeffc ("netconsole: fix
multiple race conditions") from the net tree and commit 22ded57729e6
("netconsole: Convert to pr_<level>") from the net-next tree.

(Thanks for removing that spare blank line :-))

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/netconsole.c
index c9a15925a1f7,a8ef4c4b94be..000000000000
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@@ -333,18 -336,14 +335,18 @@@ static ssize_t store_enabled(struct net
  		netpoll_print_options(&nt->np);
 =20
  		err =3D netpoll_setup(&nt->np);
 -		if (err) {
 -			mutex_unlock(&nt->mutex);
 +		if (err)
  			return err;
 -		}
 =20
- 		printk(KERN_INFO "netconsole: network logging started\n");
+ 		pr_info("network logging started\n");
 -
  	} else {	/* 0 */
 +		/* We need to disable the netconsole before cleaning it up
 +		 * otherwise we might end up in write_msg() with
 +		 * nt->np.dev =3D=3D NULL and nt->enabled =3D=3D 1
 +		 */
 +		spin_lock_irqsave(&target_list_lock, flags);
 +		nt->enabled =3D 0;
 +		spin_unlock_irqrestore(&target_list_lock, flags);
  		netpoll_cleanup(&nt->np);
  	}
 =20

--Signature=_Wed__30_Oct_2013_13_14_13_+1100_M2eGa+aZxh.SWkwU
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJScGt5AAoJEMDTa8Ir7ZwVB88P/jc+1moeyOiW1LD5b0WAp2Xf
Cy3mnffXsXc4mu9AkHPHidyI0fyXzO9sWiuR53Q8ezGep8Zc5GsS47oRKLxNzmwe
zTtO33cAt/FYQuyw8bezzcGeytdt3CLm0AK0n1LX6We6+K2DQU7Ky+XUf1+82Hn8
SQqu4AYfR2lqmPZRgR3492gTOXeO+PRf+vMAsEDQu7kwZzf/b54FGNjGDttU25s+
NLmfVVAxlpctfY9BpwaTCUwxUhE3iH/D4g7OltLftmkvL1HWAqqdNV7nt4xrhjng
e6YiAmX6f13QswR8ZkovR6NvJWzcstN1rmH2gRe8oW8rwLQugNaPlNJwPvqebBSV
1m6NHDzjSKoHTQcaJs2QMLl+quZatQlcjWhwtmU/Qw8W/HaG8vHyHKVMQ5bkkGyV
8wALM7ujvmmswgdmNy783B4fgOo/mPo/wWi6ELY1GDUQSY9qJVtHJAuW2E4xUsBO
vLnDqDrPUoCr4dxtnFB4BCCCqwgcgS8u4PV0fFW/GevIOiELt61/y73LDhjSswk0
ed2otAimsvqKhOass51tUxtuzJIotPMXBUReGKZ+szKLpBa79KNYOGJsM1CDhgdt
o55TKET43LVEuHcAQWaDFAKwrM3V1Dx2XYAX3itHSDnppuHK5BDuN06MnOgJmBOd
0l1qiRkHaeXVEUc6I0Gk
=7mnK
-----END PGP SIGNATURE-----

--Signature=_Wed__30_Oct_2013_13_14_13_+1100_M2eGa+aZxh.SWkwU--
