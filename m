From: Harald Welte <laforge@netfilter.org>
Subject: Re: BTW
Date: Wed, 27 Oct 2004 09:43:07 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041027074307.GT18934@sunbeam.de.gnumonks.org>
References: <20041020214305.4dc40449.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="E0QWZJXrJvPb9tCa"
Cc: Linux Netdev List <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041020214305.4dc40449.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--E0QWZJXrJvPb9tCa
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Oct 20, 2004 at 09:43:05PM -0700, David S. Miller wrote:

> Linus has the tcp_diag changes in his tree from Herbert.
> So you can work on the updated version of your netlink
> changes if you wish.

Here you go. Please note I know that code way too little in order to
determine if it fully fixes all cases.

Signed-off-by: Harald Welte <laforge@netfilter.org>

diff -Nru --exclude-from=3D/sunbeam/home/laforge/scripts/dontdiff linux-2.6=
=2E9-bk7/net/ipv4/tcp_diag.c linux-2.6.9-bk7-netlink_f_multi/net/ipv4/tcp_d=
iag.c
--- linux-2.6.9-bk7/net/ipv4/tcp_diag.c	2004-10-22 18:18:52.000000000 +0200
+++ linux-2.6.9-bk7-netlink_f_multi/net/ipv4/tcp_diag.c	2004-10-22 19:50:43=
=2E000000000 +0200
@@ -108,7 +108,7 @@
 }
=20
 static int tcpdiag_fill(struct sk_buff *skb, struct sock *sk,
-			int ext, u32 pid, u32 seq)
+			int ext, u32 pid, u32 seq, u16 nlmsg_flags)
 {
 	struct inet_opt *inet =3D inet_sk(sk);
 	struct tcp_opt *tp =3D tcp_sk(sk);
@@ -235,6 +235,7 @@
 	}
=20
 	nlh->nlmsg_len =3D skb->tail - b;
+	nlh->nlmsg_flags =3D nlmsg_flags;
 	return skb->len;
=20
 nlmsg_failure:
@@ -291,7 +292,7 @@
=20
 	if (tcpdiag_fill(rep, sk, req->tcpdiag_ext,
 			 NETLINK_CB(in_skb).pid,
-			 nlh->nlmsg_seq) <=3D 0)
+			 nlh->nlmsg_seq, 0) <=3D 0)
 		BUG();
=20
 	err =3D netlink_unicast(tcpnl, rep, NETLINK_CB(in_skb).pid, MSG_DONTWAIT);
@@ -497,7 +498,7 @@
 	}
=20
 	return tcpdiag_fill(skb, sk, r->tcpdiag_ext, NETLINK_CB(cb->skb).pid,
-			    cb->nlh->nlmsg_seq);
+			    cb->nlh->nlmsg_seq, NLM_F_MULTI);
 }
=20
 static int tcpdiag_fill_req(struct sk_buff *skb, struct sock *sk,
@@ -512,6 +513,7 @@
=20
 	nlh =3D NLMSG_PUT(skb, pid, seq, TCPDIAG_GETSOCK, sizeof(*r));
 	r =3D NLMSG_DATA(nlh);
+	nlh->nlmsg_flags =3D NLM_F_MULTI;
=20
 	r->tcpdiag_family =3D sk->sk_family;
 	r->tcpdiag_state =3D TCP_SYN_RECV;
diff -Nru --exclude-from=3D/sunbeam/home/laforge/scripts/dontdiff linux-2.6=
=2E9-bk7/net/xfrm/xfrm_user.c linux-2.6.9-bk7-netlink_f_multi/net/xfrm/xfrm=
_user.c
--- linux-2.6.9-bk7/net/xfrm/xfrm_user.c	2004-10-18 23:54:32.000000000 +0200
+++ linux-2.6.9-bk7-netlink_f_multi/net/xfrm/xfrm_user.c	2004-10-22 18:17:4=
2.000000000 +0200
@@ -351,7 +351,10 @@
 	nlh =3D NLMSG_PUT(skb, NETLINK_CB(in_skb).pid,
 			sp->nlmsg_seq,
 			XFRM_MSG_NEWSA, sizeof(*p));
-	nlh->nlmsg_flags =3D 0;
+	if (NETLINK_CB(in_skb).pid && (count || sp->this_idx))
+		nlh->nlmsg_flags =3D NLM_F_MULTI;
+	else
+		nlh->nlmsg_flags =3D 0;
=20
 	p =3D NLMSG_DATA(nlh);
 	copy_to_user_state(x, p);
--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--E0QWZJXrJvPb9tCa
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBf1GLXaXGVTD0i/8RAhdOAJ9UHxgMjL9Av6voX1gt+Yd3wRlWtACgrkkd
kBtfrVPlGv6VJThvpfhtfH4=
=+1IW
-----END PGP SIGNATURE-----

--E0QWZJXrJvPb9tCa--
