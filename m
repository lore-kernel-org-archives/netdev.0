From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH 1/4] Netfilter: Merge ipt_LOG and ip6_LOG into xt_LOG
Date: Thu, 01 Mar 2012 22:39:15 +0100
Message-ID: <4F4FEC83.6090504@nod.at>
References: <1328400892-22409-1-git-send-email-richard@nod.at> <1328400892-22409-3-git-send-email-richard@nod.at> <20120301112732.GA6806@1984>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig071856318EA3679E1D7573C8"
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, eric.dumazet@gmail.com,
	jengelh@medozas.de, rostedt@goodmis.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120301112732.GA6806@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig071856318EA3679E1D7573C8
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Am 01.03.2012 12:27, schrieb Pablo Neira Ayuso:
> While merging ipt_LOG and ip6t_LOG, you introduced some bug that
> corrupts the log line. Note the extra PROTO=3D, I don't have any UDPLIT=
E
> traffic here.
>=20
> Looks like a missing break in one switch.

I got confused by my own logic. :-\
Does the attached patch fix the issue?
It's based on "Netfilter: xt_LOG: Add timestamp support".

Thanks,
//richard

diff --git a/net/netfilter/xt_LOG.c b/net/netfilter/xt_LOG.c
index 4e392cf..019fb64 100644
--- a/net/netfilter/xt_LOG.c
+++ b/net/netfilter/xt_LOG.c
@@ -269,12 +269,14 @@ static void dump_ipv4_packet(struct sbuff *m,
 				    ntohs(ih->frag_off) & IP_OFFSET,
 				    iphoff+ih->ihl*4, logflags))
 			return;
+		break;
 	case IPPROTO_UDP:
 	case IPPROTO_UDPLITE:
 		if (dump_udp_header(m, skb, ih->protocol,
 				    ntohs(ih->frag_off) & IP_OFFSET,
 				    iphoff+ih->ihl*4))
 			return;
+		break;
 	case IPPROTO_ICMP: {
 		struct icmphdr _icmph;
 		const struct icmphdr *ich;
@@ -723,10 +725,12 @@ static void dump_ipv6_packet(struct sbuff *m,
 		if (dump_tcp_header(m, skb, currenthdr, fragment, ptr,
 		    logflags))
 			return;
+		break;
 	case IPPROTO_UDP:
 	case IPPROTO_UDPLITE:
 		if (dump_udp_header(m, skb, currenthdr, fragment, ptr))
 			return;
+		break;
 	case IPPROTO_ICMPV6: {
 		struct icmp6hdr _icmp6h;
 		const struct icmp6hdr *ic;


--------------enig071856318EA3679E1D7573C8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQEcBAEBAgAGBQJPT+yKAAoJEN9758yqZn9euysH/2G19o/m9i58iOu/hE+UzpQs
JmvR5mqX5uNqB/uuEkpgF6mZiVtZkHvGi37psT0QGbtSW8s69S+bbmeXnWEhsRhx
ly+Z7uNqaOuE4FAj+nGzaOGaYyFars/VT/m+MRZLUgx7W1kF8fEv2XCTb9D4vp6e
RG91/m1dyKIu4gQaJAMecieE7U8NlofC1cV+5I+uJ93ZbnaLva1rlRwlu7i7VHDM
nes4N9f902PUdc9Li/06v4bYzecUQVBa547iyCd7J6XjYxJYRkEayE/FGvaKTOUV
FaP5ZHdPw92PfksnHFpEfeDlAhnfw9idXW8psdzAP0/Fh3Fupok6AgInA9Qyv+g=
=dIu+
-----END PGP SIGNATURE-----

--------------enig071856318EA3679E1D7573C8--
