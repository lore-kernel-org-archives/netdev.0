From: Arjan van de Ven <arjanv@redhat.com>
Subject: Re: [PATCH 5/14 linux-2.6.7-rc1] prism54: new prism54 kernel
	compatibility
Date: Mon, 24 May 2004 10:53:50 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1085388830.2780.9.camel@laptop.fenrus.com>
References: <20040524083220.GF3330@ruslug.rutgers.edu>
Reply-To: arjanv@redhat.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-0laYfChQ5D1aekppT8aD"
Cc: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        prism54-devel@prism54.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "Luis R. Rodriguez" <mcgrof@studorgs.rutgers.edu>
In-Reply-To: <20040524083220.GF3330@ruslug.rutgers.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-0laYfChQ5D1aekppT8aD
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2004-05-24 at 10:32, Luis R. Rodriguez wrote:
> 2004-03-20      Margit Schubert-While <margitsw@t-online.de>
>=20
> * isl_38xx.[ch], isl_ioctl.c, islpci_dev.[ch], islpci_eth.c
>   islpci_hotplug.c, islpci_mgt.[ch], oid_mgt.c: Adopt new
>   prism54 kernel compatibility.
>=20
> * prismcompat.h, prismcompat24.h: New compatibility work


ewwww this makes the driver quite a bit less readable!

for example

-#if LINUX_VERSION_CODE >=3D KERNEL_VERSION(2,6,0)
-       /* This is 2.6 specific, nicer, shorter, but not in 2.4 yet */
-       DEFINE_WAIT(wait);
-       prepare_to_wait(&priv->reset_done, &wait, TASK_UNINTERRUPTIBLE);
-#else
-       DECLARE_WAITQUEUE(wait, current);
-       set_current_state(TASK_UNINTERRUPTIBLE);
-       add_wait_queue(&priv->reset_done, &wait);
-#endif
+       PRISM_DEFWAITQ(priv->reset_done, wait)

why not just make a DEFINE_WAIT() and prepare_to_wait() macro for 2.4
instead ?? so that you can just have the 2.6 version in the code and do
2.4 compat in a clean header, as opposed to fouling up the entire driver
with it.

--=-0laYfChQ5D1aekppT8aD
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBAsbgexULwo51rQBIRAnv7AKCQgWMFXIuEr8/uf/0l1eNFzWrBIQCdGnSm
d0fnurotkHis/i4dBYZMppc=
=/pHk
-----END PGP SIGNATURE-----

--=-0laYfChQ5D1aekppT8aD--
