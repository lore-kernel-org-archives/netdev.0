From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: manual merge of the random tree with the net-next
 tree
Date: Wed, 13 Nov 2013 07:46:57 +1100
Message-ID: <20131113074657.287f83d9669c8144865a77b6@canb.auug.org.au>
References: <20131112155549.c160273993147244ed6bc81d@canb.auug.org.au>
	<5281ED01.5020204@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__13_Nov_2013_07_46_57_+1100__r00taSe=7PqrdsY"
Cc: "Theodore Ts'o" <tytso@mit.edu>, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from haggis.pcug.org.au ([203.10.76.10]:37096 "EHLO
	members.tip.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756604Ab3KLUrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 15:47:08 -0500
In-Reply-To: <5281ED01.5020204@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Wed__13_Nov_2013_07_46_57_+1100__r00taSe=7PqrdsY
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Daniel,

On Tue, 12 Nov 2013 09:55:29 +0100 Daniel Borkmann <dborkman@redhat.com> wr=
ote:
>
> On 11/12/2013 05:55 AM, Stephen Rothwell wrote:
> >
> > Today's linux-next merge of the random tree got a conflict in
> > drivers/char/random.c between commit 0244ad004a54 ("random32: add
> > prandom_reseed_late() and call when nonblocking pool becomes
> > initialized") from the net-next tree and commit 301f0595c0e7 ("random:
> > printk notifications for urandom pool initialization") from the random
> > tree.
> >
> > I fixed it up (probably not properly - see below) and can carry the fix
> > as necessary (no action is required).
>=20
> As per Hannes' suggestion, the result should look like (see cover
> letter in [1]):
>=20
> if (r->entropy_total > 128) {
> 	r->initialized =3D 1;
> 	r->entropy_total =3D 0;
> 	if (r =3D=3D &nonblocking_pool) {
> 		prandom_reseed_late();
> 		pr_notice("random: %s pool is initialized\n",
> 			  r->name);
> 	}
> }

I will use that from today.  Thanks.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Wed__13_Nov_2013_07_46_57_+1100__r00taSe=7PqrdsY
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSgpPGAAoJEMDTa8Ir7ZwVvyUP/iP6icK/bD8+o5JekeVpKc+i
68aNrUUngmae6JPgobaeI5lYaDRGLuCHnANnZPAugN1PTyeHLUMWfdb/YJeprDAo
1NA7Oohwoc5UP+7f3rsxPA2e0us0x7JLcEMzUH4vkmWx8JST1NfBKqlbwtc4tiHP
UtxKvGMQzpI5lsJQK/gfEHRw5bS9j4uG98JbX1aHCGQv5eVU31AXF8dyKF1TZhXb
w/NZcY/W6B5PwiiMeZBGxvHEvfQnI45XBieatDxmkjuhX8IzuOh4wKz4nsOD+YXJ
WjJ1mnktGPR63b2ymRqGl4zhHMTZABTc0/BqcSYEiY3Cdd5CuVHcKGPuQPr2zpP4
p7MSbr7uzdJJaTvi7E3EYd1itoomNVkqXrmsy7TE7UJLCRSIlnSoqV+kJtoy8HUE
yqw/tSDM08a8wGjQesdb/MXIkUQE9wZfzElACFgNfZ+aZGw/rCMJib62EHlqpRMO
eMNBQ74RObeSOL80dJo6kQUPxQ1+9V4CT0EQeZQgXTJ903sFulu5rucgXuvP/iH7
K1EHM9c8JW41TvcM4+p+1arTA0vQ2jHN8eRfETLnJNtR0tUilWRftuq7YyabNONZ
0J8FLB5glwEiub9uHgSUuX57opnh2JQ8ryywaO6wxbyHaTrJAwy62ojwF/xDKqGs
IFEt4oz6MU2bW2bRhflp
=Xf8o
-----END PGP SIGNATURE-----

--Signature=_Wed__13_Nov_2013_07_46_57_+1100__r00taSe=7PqrdsY--
