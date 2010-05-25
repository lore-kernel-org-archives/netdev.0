From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the final tree
Date: Tue, 25 May 2010 14:10:46 +1000
Message-ID: <20100525141046.975afe1f.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__25_May_2010_14_10_46_+1000_Wsd_yZi00YjEYOvi"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__25_May_2010_14_10_46_+1000_Wsd_yZi00YjEYOvi
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

After merging the final tree, today's linux-next build (powerpc
allyesconfig) failed like this:

In file included from net/socket.c:97:
include/net/cls_cgroup.h: In function 'task_cls_classid':
include/net/cls_cgroup.h:33: error: request for member 'classid' in somethi=
ng not a structure or union
In file included from net/core/sock.c:126:
include/net/cls_cgroup.h: In function 'task_cls_classid':
include/net/cls_cgroup.h:33: error: request for member 'classid' in somethi=
ng not a structure or union
In file included from net/sched/cls_cgroup.c:23:
include/net/cls_cgroup.h: In function 'task_cls_classid':
include/net/cls_cgroup.h:33: error: request for member 'classid' in somethi=
ng not a structure or union

CONFIG_CGROUPS=3Dy, CONFIG_NET_CLS_CGROUP=3Dy

Caused by commit f845172531fb7410c7fb7780b1a6e51ee6df7d52 ("cls_cgroup:
Store classid in struct sock") from the net-current tree.

I have reverted that commit for today (and commit
8286274284e15b11b0f531b6ceeef21fbe00a8dd "tun: Update classid on packet
injection" that depends on it).
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__25_May_2010_14_10_46_+1000_Wsd_yZi00YjEYOvi
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkv7TcYACgkQjjKRsyhoI8zUmgCeMCg+SZSDDaXdnG6V/mm5c2bt
AJUAni7pzMR/16ME6zt4pM+VJ1UMZbDp
=wNtP
-----END PGP SIGNATURE-----

--Signature=_Tue__25_May_2010_14_10_46_+1000_Wsd_yZi00YjEYOvi--
