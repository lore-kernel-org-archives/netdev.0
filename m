From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net-next tree
Date: Tue, 30 Sep 2014 13:13:54 +1000
Message-ID: <20140930131354.792033e7@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/M2W1CfRL_6gzZO6QZN1bLm9"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/M2W1CfRL_6gzZO6QZN1bLm9
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net-next tree, today's linux-next build (powerpc
ppc64_defconfig) failed like this:

net/bridge/br_nf_core.c:77:1: error: expected identifier or '(' before '{' =
token
 {
 ^
net/bridge/br_nf_core.c:88:12: error: redefinition of 'br_nf_core_init'
 int __init br_nf_core_init(void)
            ^
In file included from net/bridge/br_nf_core.c:23:0:
net/bridge/br_private.h:762:19: note: previous definition of 'br_nf_core_in=
it' was here
 static inline int br_nf_core_init(void) { return 0; }
                   ^
net/bridge/br_nf_core.c:93:6: error: redefinition of 'br_nf_core_fini'
 void br_nf_core_fini(void)
      ^
In file included from net/bridge/br_nf_core.c:23:0:
net/bridge/br_private.h:763:20: note: previous definition of 'br_nf_core_fi=
ni' was here
 static inline void br_nf_core_fini(void) {}
                    ^

Caused by commit 34666d467cbf ("netfilter: bridge: move br_netfilter
out of the core").  This build has CONFIG_BRIDGE_NETFILTER not set ...

I have applied the following patch for today:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 30 Sep 2014 13:09:09 +1000
Subject: [PATCH] netfilter: bridge: don't build br_nf_core unless necessary

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 net/bridge/Makefile | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/bridge/Makefile b/net/bridge/Makefile
index 5e3eac5dc8b9..eb653a225397 100644
--- a/net/bridge/Makefile
+++ b/net/bridge/Makefile
@@ -6,12 +6,11 @@ obj-$(CONFIG_BRIDGE) +=3D bridge.o
=20
 bridge-y	:=3D br.o br_device.o br_fdb.o br_forward.o br_if.o br_input.o \
 			br_ioctl.o br_stp.o br_stp_bpdu.o \
-			br_stp_if.o br_stp_timer.o br_netlink.o \
-			br_nf_core.o
+			br_stp_if.o br_stp_timer.o br_netlink.o
=20
 bridge-$(CONFIG_SYSFS) +=3D br_sysfs_if.o br_sysfs_br.o
=20
-obj-$(CONFIG_BRIDGE_NETFILTER) +=3D br_netfilter.o
+obj-$(CONFIG_BRIDGE_NETFILTER) +=3D br_netfilter.o br_nf_core.o
=20
 bridge-$(CONFIG_BRIDGE_IGMP_SNOOPING) +=3D br_multicast.o br_mdb.o
=20
--=20
2.1.1

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/M2W1CfRL_6gzZO6QZN1bLm9
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUKh/4AAoJEMDTa8Ir7ZwV1HoP/Rgscw6t1wuvsZWXpYzNe3f7
ZQPVcdmF8dmD4SNcaUcdCH9AUFPlSabDixDs7vnNrSYr7F06elKzKWC52Io7Lka+
sa7gyf2kN18h/WwcB0//+2s+bXJ9M9ilYm0gsYesbs0kQHBoHCctLjUHNnJmuRtu
QSJ5kKNgbzjQ78IoN7DA93r3079PuXapqbzasXJFJGpUdWIymhlhgjcgWlFYLroG
3t8wEtzU0qmhacpm5w5C3d74tyPjuaYSgjVtNS0FSURqUgEscT0myX+BMJkqr2k4
BB36oe7xEQjTewC6vT5dZ076Mt9zONuTPldqAYnBnaCcKfbFtYVgk89fijYcN41T
P9GRxSC4EfBd7BSrNPTJ6EgP36rlc07juTgoB2ctHLzOZ+l9TEzpQwJQ1x6DC6Zp
LcxEMxMAt9fSyKbMoc8963+V8du0GLRk//6a+TNT+Dia/3zmQz+H+YI9+u/57sQg
XBeZ/7ac2+sw4xnNULkW2Iv3SXNXkqVDz/znwV17CK0EAI5hHD6RDDE+PHRyB5pg
jeilixGpISUIBu2xNfeiAI/SefAuM6h/IhZnEd/1OrkbLuZd/XMwVbDfpecTBi5S
SOPB2u9tjq03PEly+SXHFoxfJrD3ThLfvLHv/qRG2Zv9/mHfDoC1W7LLFkNyxVkX
q+wzmDh/nAWJ51ItU/6a
=rD2b
-----END PGP SIGNATURE-----

--Sig_/M2W1CfRL_6gzZO6QZN1bLm9--
