From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after final merge (net tree)
Date: Fri, 19 Feb 2010 17:37:13 +1100
Message-ID: <20100219173713.e3f9f386.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Fri__19_Feb_2010_17_37_13_+1100_h=7=l5zEcNs2EbDM"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Kristoffer Glembo <kristoffer@gaisler.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__19_Feb_2010_17_37_13_+1100_h=7=l5zEcNs2EbDM
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

After merging the scsi-post-merge tree, today's linux-next build (powerpc
allyesconfig) failed like this:

drivers/net/greth.c: In function 'greth_of_probe':
drivers/net/greth.c:1414: error: implicit declaration of function 'of_iorem=
ap'
drivers/net/greth.c:1414: error: 'struct of_device' has no member named 're=
source'
drivers/net/greth.c:1415: error: 'struct of_device' has no member named 're=
source'
drivers/net/greth.c:1426: error: 'struct of_device' has no member named 'ir=
qs'
drivers/net/greth.c:1580: error: implicit declaration of function 'of_iounm=
ap'
drivers/net/greth.c:1580: error: 'struct of_device' has no member named 're=
source'
drivers/net/greth.c:1580: error: 'struct of_device' has no member named 're=
source'
drivers/net/greth.c: In function 'greth_of_remove':
drivers/net/greth.c:1605: error: 'struct of_device' has no member named 're=
source'
drivers/net/greth.c:1605: error: 'struct of_device' has no member named 're=
source'

Caused by commit d4c41139df6e74c6fff0cbac43e51cab782133be ("net: Add
Aeroflex Gaisler 10/100/1G Ethernet MAC driver").

I assume that this driver was written and tested only on Sparc ... maybe
it should depend on SPARC?

I have reverted that commit for today.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Fri__19_Feb_2010_17_37_13_+1100_h=7=l5zEcNs2EbDM
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkt+MZkACgkQjjKRsyhoI8yIgQCeNT6IN7wV11/NGVkLunLnvvz4
em0AnA1BlnlzYYFg457sUOY1XBXYSh7+
=/m/w
-----END PGP SIGNATURE-----

--Signature=_Fri__19_Feb_2010_17_37_13_+1100_h=7=l5zEcNs2EbDM--
