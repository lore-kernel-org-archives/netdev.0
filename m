From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: status of ipchains in 2.6?
Date: Tue, 28 Oct 2003 19:23:37 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1067365417.14002.18.camel@tux.rsn.bth.se>
References: <200310280127.h9S1RM5d002140@napali.hpl.hp.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-l/3S+QrtpWkiPJDm/Ryr"
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davidm@hpl.hp.com
In-Reply-To: <200310280127.h9S1RM5d002140@napali.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-l/3S+QrtpWkiPJDm/Ryr
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2003-10-28 at 02:27, David Mosberger wrote:
> I recently discovered that ipchains is rather broken.  I noticed the
> problem on ia64, but suspect that it's likely to affect all 64-bit
> platforms (if not 32-bit platforms).  A more detailed description of
> the problem I'm seeing is here:
>=20
> 	http://tinyurl.com/sm9d
>=20
> Unlike ipchains, iptables works perfectly fine, so perhaps we just
> need to update Kconfig to discourage ipchains on ia64 (and/or other
> 64-bit platforms)?

Please try this patch that just got included in linus tree.

ChangeSet 1.1360, 2003/10/27 00:01:25-08:00, rusty@rustcorp.com.au

	[NETFILTER]: Fix ipchains oops in NAT
=09
	We updated ip_nat_setup_info to set the initialized flag and call
	place_in_hashes, but *didn't* change the call in ip_fw_compat_masq.c
	which also calls place_in_hashes() itself (again!).  Result: corrupt
	list, and next thing which lands in the same hash bucket goes boom.
=09
	Thanks to Andy Polyakov for chasing this down.


# This patch includes the following deltas:
#	           ChangeSet	1.1359  -> 1.1360=20
#	net/ipv4/netfilter/ip_fw_compat_masq.c	1.11    -> 1.12  =20
#

 ip_fw_compat_masq.c |    3 ---
 1 files changed, 3 deletions(-)


diff -Nru a/net/ipv4/netfilter/ip_fw_compat_masq.c b/net/ipv4/netfilter/ip_=
fw_compat_masq.c
--- a/net/ipv4/netfilter/ip_fw_compat_masq.c	Mon Oct 27 12:07:33 2003
+++ b/net/ipv4/netfilter/ip_fw_compat_masq.c	Mon Oct 27 12:07:33 2003
@@ -91,9 +91,6 @@
 			WRITE_UNLOCK(&ip_nat_lock);
 			return ret;
 		}
-
-		place_in_hashes(ct, info);
-		info->initialized =3D 1;
 	} else
 		DEBUGP("Masquerading already done on this conn.\n");
 	WRITE_UNLOCK(&ip_nat_lock);

--=20
/Martin

--=-l/3S+QrtpWkiPJDm/Ryr
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQA/nrQoWm2vlfa207ERArQ7AKCyccc4ksQ8ZDdHAc0ly9G9LUig/wCeLW4Z
+GAedAotQlQ3y4CImhNPiq0=
=1EDW
-----END PGP SIGNATURE-----

--=-l/3S+QrtpWkiPJDm/Ryr--
