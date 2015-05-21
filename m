From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Thu, 21 May 2015 12:59:24 +1000
Message-ID: <20150521125924.7518d904@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/8K7gOX.VGzufmDeLBcDgRti"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>,
	Tim Beale <tim.beale@alliedtelesis.co.nz>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/8K7gOX.VGzufmDeLBcDgRti
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/phy/phy.c between commit c15e10e71ce3 ("net: phy: Make sure
phy_start() always re-enables the phy interrupts") from the net tree
and commit 3e2186e02112 ("net: phy: Add state machine state transitions
debug prints") from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/phy/phy.c
index 47cd578052fc,1457ecf75dcc..000000000000
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@@ -783,7 -794,8 +808,8 @@@ void phy_state_machine(struct work_stru
  	struct delayed_work *dwork =3D to_delayed_work(work);
  	struct phy_device *phydev =3D
  			container_of(dwork, struct phy_device, state_queue);
 -	bool needs_aneg =3D false, do_suspend =3D false, do_resume =3D false;
 +	bool needs_aneg =3D false, do_suspend =3D false;
+ 	enum phy_state old_state;
  	int err =3D 0;
 =20
  	mutex_lock(&phydev->lock);

--Sig_/8K7gOX.VGzufmDeLBcDgRti
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVXUoQAAoJEMDTa8Ir7ZwVfuoP/RRG41XJzmm1WE3qq02t1FCA
BxcZOHJaeAUSppFzD2fJnmCaZJ0Ngfd9M2eGL2b8cAC9xRfVwkZRlazNe+OT1gr6
t58VfE/Mdm/LtmagXzaN3ogOkStrLS/4oA/PhwJ/VtyAT9QCYvqz75YdM0mMHIxc
kdryhMYoob52UjPFxDPeoTK2IGGoibMETKW9JAY11iecqohR98fQeTuBLwutp5p6
7tqYwZkDzxJp1ey5SW8K2OQzY+1+chrbEqsQT7UuK8ZJEu3gEK42PXO88iGoBHXR
DFaybqxdF5h75wnwZoKKfSzEhElnAS98rkqhtFfjywXVrpmZv9UwekHw7+ziyr+B
vrV+N4YEX/aNN+2s5EXt57elIKOeoxfUZSEkrKIpkUtHcwzRfwB/7kDDB0v6mNjk
e2THSg86RT/vNqTQyvetwEohYz/1SdUz7nqm/88uGAI9oWSXRjbQattpadbJlg6U
00YeWx0Z7h+ENEoO6bqgshtxD4X85OLpK1HEGOL1Vr9BQaBiwVhGQEBFbzAr2gqQ
kf3haRs3MwL4C4M6INPtBn1KTIjLxmLDD+RiyRck2qRbfwroh2nIlUOB/Q3ogBfh
KdnfvnOX1TfAqNv3+InS/u4RjvJj/HhxSQfAYzUNMCyo5Hh4KvK9nFOBZUhaDY4t
gjMTvIZype9/73yztKz+
=aAEk
-----END PGP SIGNATURE-----

--Sig_/8K7gOX.VGzufmDeLBcDgRti--
