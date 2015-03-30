From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the vfs tree
Date: Mon, 30 Mar 2015 14:08:05 +1100
Message-ID: <20150330140805.24e90c92@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/wnyHUp6xumNdVgYfZcjMFG5"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	"tadeusz.struk@intel.com" <tadeusz.struk@intel.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/wnyHUp6xumNdVgYfZcjMFG5
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/compat.c between commit 774157aa4897 ("net: switch importing msghdr
from userland to {compat_,}import_iovec()") from the vfs tree and
commit 0345f93138b2 ("net: socket: add support for async operations")
from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/compat.c
index 0e34814592e6,c4b6b0f43d5d..000000000000
--- a/net/compat.c
+++ b/net/compat.c
@@@ -79,9 -79,15 +79,11 @@@ int get_compat_msghdr(struct msghdr *km
  	if (nr_segs > UIO_MAXIOV)
  		return -EMSGSIZE;
 =20
+ 	kmsg->msg_iocb =3D NULL;
+=20
 -	err =3D compat_rw_copy_check_uvector(save_addr ? READ : WRITE,
 -					   compat_ptr(uiov), nr_segs,
 -					   UIO_FASTIOV, *iov, iov);
 -	if (err >=3D 0)
 -		iov_iter_init(&kmsg->msg_iter, save_addr ? READ : WRITE,
 -			      *iov, nr_segs, err);
 -	return err;
 +	return compat_import_iovec(save_addr ? READ : WRITE,
 +				   compat_ptr(uiov), nr_segs,
 +				   UIO_FASTIOV, iov, &kmsg->msg_iter);
  }
 =20
  /* Bleech... */

--Sig_/wnyHUp6xumNdVgYfZcjMFG5
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVGL4aAAoJEMDTa8Ir7ZwV+UEP/isFCYyrjAddFE11OwpdbjsR
seDYAQ7qm7V5nMg4HvlRqhBQQ0NZBBGaew/jzRL30PBb//07Q6KyamVXV+Y4xlSA
tatoSUh9TawIikTyfCz0zvPtnk02odFPFDl1rETirM17PfMLaVswYoQgQgVWwEHC
WP6xa2KORRMvPEBDYB00DN9j3qFjpoF2anZzyP0ot07k5jvPbam/gZgw2FEzw8qn
fkLJpmLG+s+9+4l5j3CoaOuISJMKDHh/ulRyu7CwMOII73Z9G4hzIF81WbEuSNRw
ItWFOYt3AKrGrXydxNu0IeIIlh5ncRrOoH2LvNOIb/pSRJm+3ppndvkCmfb0ctzA
4UDTVHc94EyUMuQlkVQg/XNHl96AaF0ufl2X6yF07M6fCjQ5OrrqaJTfWBE7q+7n
c5KizKrg5hn8DfXweAio5ecrvtNGLcIadBBDY7XlFr2bmoD+fjgAZnf2tX/LvTBe
mXKF0SxdZ3cltwTLby4g/duTN1rK57y1QCV75BoqoM201GYj653WgakrsqMEnR/h
xUkXWuOTyY+Wei54p9spLZRMaHNjXfYHtfV6uiqbqAhz7eWHP3qg1Cpw8Y9h+YZU
QARlKP+TSUv7I1m4w8gyEfpUPIDvnK7ZTXX7MgRoPdQ4Hjq9QVIzVAwhBCobqyGB
MJdqRE5dfBwxVBH4/7yD
=jmEI
-----END PGP SIGNATURE-----

--Sig_/wnyHUp6xumNdVgYfZcjMFG5--
