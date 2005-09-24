From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH] [NETFILTER] ip_conntrack: Update event cache when status
	changes
Date: Sat, 24 Sep 2005 20:50:20 +0200
Message-ID: <20050924185020.GC731@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="vwukjNKnt4OidM22"
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


--vwukjNKnt4OidM22
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave!

While preparing the first release of libnfnetlink,
libnfnetlink_conntrack and the "conntrack" userspace program, I found
out that some events are never generated within the kernel.  Please
apply the patch below, thans.


[NETFILTER] ip_conntrack: Update event cache when status changes

The GRE, SCTP and TCP protocol helpers did not call ip_conntrack_event_cach=
e()
when updating ct->status.  This patch adds the respective calls.

Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit 1699521ab4e23ba4dd9f8bdd894393b8e109fe43
tree 2e0e4becf37fc85de0206eb7d381c3d849075ce8
parent 5a9087bd9bf78e3ca131a84a8eed06d6c31396dc
author Harald Welte <laforge@hanuman.de.gnumonks.org> Sat, 24 Sep 2005 20:4=
7:41 +0200
committer Harald Welte <laforge@hanuman.de.gnumonks.org> Sat, 24 Sep 2005 2=
0:47:41 +0200

 net/ipv4/netfilter/ip_conntrack_proto_gre.c  |    1 +
 net/ipv4/netfilter/ip_conntrack_proto_sctp.c |    1 +
 net/ipv4/netfilter/ip_conntrack_proto_tcp.c  |    3 ++-
 3 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/netfilter/ip_conntrack_proto_gre.c b/net/ipv4/netfilt=
er/ip_conntrack_proto_gre.c
--- a/net/ipv4/netfilter/ip_conntrack_proto_gre.c
+++ b/net/ipv4/netfilter/ip_conntrack_proto_gre.c
@@ -247,6 +247,7 @@ static int gre_packet(struct ip_conntrac
 				   ct->proto.gre.stream_timeout);
 		/* Also, more likely to be important, and not a probe. */
 		set_bit(IPS_ASSURED_BIT, &ct->status);
+		ip_conntrack_event_cache(IPCT_STATUS, skb);
 	} else
 		ip_ct_refresh_acct(ct, conntrackinfo, skb,
 				   ct->proto.gre.timeout);
diff --git a/net/ipv4/netfilter/ip_conntrack_proto_sctp.c b/net/ipv4/netfil=
ter/ip_conntrack_proto_sctp.c
--- a/net/ipv4/netfilter/ip_conntrack_proto_sctp.c
+++ b/net/ipv4/netfilter/ip_conntrack_proto_sctp.c
@@ -416,6 +416,7 @@ static int sctp_packet(struct ip_conntra
 		&& newconntrack =3D=3D SCTP_CONNTRACK_ESTABLISHED) {
 		DEBUGP("Setting assured bit\n");
 		set_bit(IPS_ASSURED_BIT, &conntrack->status);
+		ip_conntrack_event_cache(IPCT_STATUS, skb);
 	}
=20
 	return NF_ACCEPT;
diff --git a/net/ipv4/netfilter/ip_conntrack_proto_tcp.c b/net/ipv4/netfilt=
er/ip_conntrack_proto_tcp.c
--- a/net/ipv4/netfilter/ip_conntrack_proto_tcp.c
+++ b/net/ipv4/netfilter/ip_conntrack_proto_tcp.c
@@ -1014,7 +1014,8 @@ static int tcp_packet(struct ip_conntrac
 		/* Set ASSURED if we see see valid ack in ESTABLISHED=20
 		   after SYN_RECV or a valid answer for a picked up=20
 		   connection. */
-			set_bit(IPS_ASSURED_BIT, &conntrack->status);
+		set_bit(IPS_ASSURED_BIT, &conntrack->status);
+		ip_conntrack_event_cache(IPCT_STATUS, skb);
 	}
 	ip_ct_refresh_acct(conntrack, ctinfo, skb, timeout);
=20
--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--vwukjNKnt4OidM22
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFDNZ/sXaXGVTD0i/8RAjZ+AJ9vgW0o0wDVdwRbEfrRxShIo3HZSwCfcO4f
PG2OfQ+r3CUgFXDnSlTDbSA=
=2TkF
-----END PGP SIGNATURE-----

--vwukjNKnt4OidM22--
