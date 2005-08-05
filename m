From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH] ctnetlink: make sure event order is correct
Date: Fri, 5 Aug 2005 18:27:38 +0200
Message-ID: <20050805162738.GD4033@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="T7mxYSe680VjQnyC"
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


--T7mxYSe680VjQnyC
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave, please apply.

[NETFILTER] ctnetlink: make sure event order is correct

The following sequence is displayed during events dumping of an ICMP
connection: [NEW] [DESTROY] [UPDATE]

This happens because the event IPCT_DESTROY is delivered in
death_by_timeout(), that is called from the icmp protocol helper
(ct->timeout.function) once we see the reply.

To fix this, we move this event to destroy_conntrack().

Signed-off-by: Pablo Neira Ayuso <pablo@eurodev.net>
Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit cb90ab7c56471a733f5a91a3ec2cfbd45093e8a0
tree cf84842a1e41dcaefd9934f9752df2ca977831d7
parent 570b2053cc2c68da90b71add2a4f4366673b48d8
author Harald Welte <laforge@netfilter.org> Fr, 05 Aug 2005 14:28:31 +0200
committer Harald Welte <laforge@netfilter.org> Fr, 05 Aug 2005 14:28:31 +02=
00

 net/ipv4/netfilter/ip_conntrack_core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/netfilter/ip_conntrack_core.c b/net/ipv4/netfilter/ip=
_conntrack_core.c
--- a/net/ipv4/netfilter/ip_conntrack_core.c
+++ b/net/ipv4/netfilter/ip_conntrack_core.c
@@ -327,6 +327,7 @@ destroy_conntrack(struct nf_conntrack *n
 	IP_NF_ASSERT(atomic_read(&nfct->use) =3D=3D 0);
 	IP_NF_ASSERT(!timer_pending(&ct->timeout));
=20
+	ip_conntrack_event(IPCT_DESTROY, ct);
 	set_bit(IPS_DYING_BIT, &ct->status);
=20
 	/* To make sure we don't get any weird locking issues here:
@@ -366,7 +367,6 @@ static void death_by_timeout(unsigned lo
 {
 	struct ip_conntrack *ct =3D (void *)ul_conntrack;
=20
-	ip_conntrack_event(IPCT_DESTROY, ct);
 	write_lock_bh(&ip_conntrack_lock);
 	/* Inside lock so preempt is disabled on module removal path.
 	 * Otherwise we can get spurious warnings. */
--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--T7mxYSe680VjQnyC
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC85N6XaXGVTD0i/8RArZAAJ0TrF0WD6M2PZiQ5HME9HV8Nht/RQCgtV/6
cUtrn+ffkm+bLujs4cmqtZY=
=E+Fm
-----END PGP SIGNATURE-----

--T7mxYSe680VjQnyC--
