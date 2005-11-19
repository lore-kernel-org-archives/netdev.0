From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH] NETFILTER arp_tables: Fix NUMA optimization
Date: Sat, 19 Nov 2005 11:31:31 +0100
Message-ID: <20051119103131.GE20775@sunbeam.de.gnumonks.org>
References: <20051117144328.GG14201@sunbeam.de.gnumonks.org>
	<437CA009.4020006@cosmosbay.com>
	<20051118.160043.119281166.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="tmoQ0UElFV5VgXgH"
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	dada1@cosmosbay.com
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20051118.160043.119281166.davem@davemloft.net>
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


--tmoQ0UElFV5VgXgH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave!

On Fri, Nov 18, 2005 at 04:00:43PM -0800, David S. Miller wrote:

> I've put the patch into the net-2.6.16 tree with the obvious
> fix Eric points out.

There's another one that I detected while merging those changes with
x_tables (painful).  Please merge:


[NETFILTER] arp_tables: Fix bug introduced with NUMA aware allocation

This fix shows how bad I am with copy & paste.

Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit 4fa8b41b4adc117876114c149885fc8921fcabde
tree 950bd802e3daf69ad55fc203765c31ebead4fe5d
parent a7b935151849464c804437ee411dc64641c6f298
author Harald Welte <laforge@netfilter.org> Sat, 19 Nov 2005 11:29:40 +0100
committer Harald Welte <laforge@netfilter.org> Sat, 19 Nov 2005 11:29:40 +0=
100

 net/ipv4/netfilter/arp_tables.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_table=
s.c
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -757,7 +757,7 @@ static int translate_table(const char *n
 	/* And one copy for every other CPU */
 	for_each_cpu(i) {
 		if (newinfo->entries[i] && newinfo->entries[i] !=3D entry0)
-			memcpy(newinfo->entries[smp_processor_id()], entry0, newinfo->size);
+			memcpy(newinfo->entries[i], entry0, newinfo->size);
 	}
=20
 	return ret;
--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--tmoQ0UElFV5VgXgH
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQFDfv8DXaXGVTD0i/8RAsDwAJ9CTytH6TONPd17hzLw8tvWnhXWlgCfS8jQ
ICeoV0dPyhRJYQC+9BFwrcM=
=g/h5
-----END PGP SIGNATURE-----

--tmoQ0UElFV5VgXgH--
