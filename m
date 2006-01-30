From: Harald Welte <laforge@netfilter.org>
Subject: [NETFILTER] NAT sequence adjustment: Save eight bytes per conntrack
Date: Tue, 31 Jan 2006 00:22:09 +0100
Message-ID: <20060130232209.GG4603@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ynxsfku+JT9DNNkq"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
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


--ynxsfku+JT9DNNkq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave!

Please apply this humble little step towards ip_conntrack shrinking,
thanks!

[NETFILTER] NAT sequence adjustment: Save eight bytes per conntrack

This patch reduces the size of 'struct ip_conntrack' on systems with NAT
by eight bytes.  The sequence number delta values can be int16_t, since
we only support one sequence number modification per window anyway, and
one such modification is not going to exceed 32kB ;)

Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit 94d3d40c84672b74e59ea5252f61602610e1513e
tree 63e5ae5174af9f982be6d8d1bbe11e750e4ace32
parent e3c7a1f99300fbd6de35a40fcd9c4dc1b0fbfee2
author Harald Welte <laforge@netfilter.org> Fri, 27 Jan 2006 16:03:45 +0100
committer Harald Welte <laforge@netfilter.org> Fri, 27 Jan 2006 16:03:45 +0=
100

 include/linux/netfilter_ipv4/ip_nat.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/netfilter_ipv4/ip_nat.h b/include/linux/netfilte=
r_ipv4/ip_nat.h
index 41a107d..e9f5ed1 100644
--- a/include/linux/netfilter_ipv4/ip_nat.h
+++ b/include/linux/netfilter_ipv4/ip_nat.h
@@ -23,7 +23,7 @@ struct ip_nat_seq {
 	 * modification (if any) */
 	u_int32_t correction_pos;
 	/* sequence number offset before and after last modification */
-	int32_t offset_before, offset_after;
+	int16_t offset_before, offset_after;
 };
=20
 /* Single range specification. */
--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--ynxsfku+JT9DNNkq
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQFD3p+hXaXGVTD0i/8RAmwtAJ4sUoPe2JOUfgYYmiG5tu330TQ7YwCeNPZm
2ir3C9KohqSxJFPpMHpW2o0=
=sFtV
-----END PGP SIGNATURE-----

--ynxsfku+JT9DNNkq--
