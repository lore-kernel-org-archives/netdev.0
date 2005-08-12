From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH] add new iptables ipt_connbytes match
Date: Fri, 12 Aug 2005 21:03:43 +0200
Message-ID: <20050812190343.GW18580@rama.de.gnumonks.org>
References: <20050811200349.GN5353@rama.de.gnumonks.org>
	<20050811.154204.102613246.davem@davemloft.net>
	<p73u0hv2xkv.fsf@verdi.suse.de> <42FC8EBC.1070505@trash.net>
	<20050812120319.GK8974@wotan.suse.de>
	<20050812153730.GR18580@rama.de.gnumonks.org>
	<20050812182355.GF22901@wotan.suse.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="XCIqNWEteo88hZlY"
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	Patrick McHardy <kaber@trash.net>, Andi Kleen <ak@suse.de>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050812182355.GF22901@wotan.suse.de>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--XCIqNWEteo88hZlY
Content-Type: multipart/mixed; boundary="doUn1Hmx68n+7ij2"
Content-Disposition: inline


--doUn1Hmx68n+7ij2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Aug 12, 2005 at 08:23:55PM +0200, Andi Kleen wrote:
> > I don't think that we're ever going to fix that bug in the old
> > {get,set}sockopt interface, but rather introduce a netlink interface
> > when pkt_tables matures.
>=20
> All new interfaces should be emulation clean, so that if the old interface
> is replaced later it should eventually work. The best way to do that
> is to use aligned_u64. Should probably put that into linux/types.h

Ok, I hope everyone is fine with this patch:

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--doUn1Hmx68n+7ij2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="48-aligned_u64.patch"
Content-Transfer-Encoding: quoted-printable

[NETFILTER] introduce and use aligned_u64 data type

As proposed by Andi Kleen, this is required esp. for x86_64 architecture,
where 64bit code needs 8byte aligned 64bit data types, but 32bit userspace
apps will only align to 4bytes.

Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit 30da9a3da187af74b2e2d00becf2d9cab3624ddd
tree 7666f6ce67e96beedc8884f1aba18ea80a20e2b1
parent 7c249f391a3b9bc86ec07d734959c532a3c7a3f6
author Harald Welte <laforge@netfilter.org> Fr, 12 Aug 2005 21:00:28 +0200
committer Harald Welte <laforge@netfilter.org> Fr, 12 Aug 2005 21:00:28 +02=
00

 include/linux/netfilter/nfnetlink_log.h      |    5 +++--
 include/linux/netfilter/nfnetlink_queue.h    |    5 +++--
 include/linux/netfilter_ipv4/ipt_connbytes.h |    4 ++--
 include/linux/types.h                        |    3 +++
 4 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/include/linux/netfilter/nfnetlink_log.h b/include/linux/netfil=
ter/nfnetlink_log.h
--- a/include/linux/netfilter/nfnetlink_log.h
+++ b/include/linux/netfilter/nfnetlink_log.h
@@ -5,6 +5,7 @@
  * and not any kind of function definitions.  It is shared between kernel =
and
  * userspace.  Don't put kernel specific stuff in here */
=20
+#include <linux/types.h>
 #include <linux/netfilter/nfnetlink.h>
=20
 enum nfulnl_msg_types {
@@ -27,8 +28,8 @@ struct nfulnl_msg_packet_hw {
 } __attribute__ ((packed));
=20
 struct nfulnl_msg_packet_timestamp {
-	u_int64_t	sec;
-	u_int64_t	usec;
+	aligned_u64	sec;
+	aligned_u64	usec;
 } __attribute__ ((packed));
=20
 #define NFULNL_PREFIXLEN	30	/* just like old log target */
diff --git a/include/linux/netfilter/nfnetlink_queue.h b/include/linux/netf=
ilter/nfnetlink_queue.h
--- a/include/linux/netfilter/nfnetlink_queue.h
+++ b/include/linux/netfilter/nfnetlink_queue.h
@@ -1,6 +1,7 @@
 #ifndef _NFNETLINK_QUEUE_H
 #define _NFNETLINK_QUEUE_H
=20
+#include <linux/types.h>
 #include <linux/netfilter/nfnetlink.h>
=20
 enum nfqnl_msg_types {
@@ -24,8 +25,8 @@ struct nfqnl_msg_packet_hw {
 } __attribute__ ((packed));
=20
 struct nfqnl_msg_packet_timestamp {
-	u_int64_t	sec;
-	u_int64_t	usec;
+	aligned_u64	sec;
+	aligned_u64	usec;
 } __attribute__ ((packed));
=20
 enum nfqnl_attr_type {
diff --git a/include/linux/netfilter_ipv4/ipt_connbytes.h b/include/linux/n=
etfilter_ipv4/ipt_connbytes.h
--- a/include/linux/netfilter_ipv4/ipt_connbytes.h
+++ b/include/linux/netfilter_ipv4/ipt_connbytes.h
@@ -16,8 +16,8 @@ enum ipt_connbytes_direction {
 struct ipt_connbytes_info
 {
 	struct {
-		u_int64_t from;	/* count to be matched */
-		u_int64_t to;	/* count to be matched */
+		aligned_u64 from;	/* count to be matched */
+		aligned_u64 to;		/* count to be matched */
 	} count;
 	u_int8_t what;		/* ipt_connbytes_what */
 	u_int8_t direction;	/* ipt_connbytes_direction */
diff --git a/include/linux/types.h b/include/linux/types.h
--- a/include/linux/types.h
+++ b/include/linux/types.h
@@ -123,6 +123,9 @@ typedef		__u64		u_int64_t;
 typedef		__s64		int64_t;
 #endif
=20
+/* this is a special 64bit data type that is 8-byte aligned */
+#define aligned_u64 unsigned long long __attribute__((aligned(8)))
+
 /*
  * The type used for indexing onto a disc or disc partition.
  * If required, asm/types.h can override it and define

--doUn1Hmx68n+7ij2--

--XCIqNWEteo88hZlY
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC/PKOXaXGVTD0i/8RAn6PAJ0chQVAfTqLvCNTV9XkrEmnzqjgkgCeMukI
vL0eXlk3o0saLqymFrnUzRA=
=5hp+
-----END PGP SIGNATURE-----

--XCIqNWEteo88hZlY--
