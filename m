From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Fri, 26 Apr 2013 13:38:29 +1000
Message-ID: <20130426133829.e9f42486705f099a362e8086@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__26_Apr_2013_13_38_29_+1000_qPRyoi4BqSgrPpY."
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__26_Apr_2013_13_38_29_+1000_qPRyoi4BqSgrPpY.
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
include/net/tcp.h between commit 093162553c33 ("tcp: force a dst refcount
when prequeue packet") from the net tree and commit b2fb4f54ecd4 ("tcp:
uninline tcp_prequeue()") from the net-next tree.

I fixed it up (I used the next-next version of tcp.h and added the
following patch) and can carry the fix as necessary (no action is
required).  Thanks for the heads up Dave!

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 26 Apr 2013 13:35:50 +1000
Subject: [PATCH] tcp: merge fixup for movemenet of tcp_prequeue

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 net/ipv4/tcp_ipv4.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 8667aaa..5dcf177 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1926,6 +1926,7 @@ bool tcp_prequeue(struct sock *sk, struct sk_buff *sk=
b)
 	    skb_queue_len(&tp->ucopy.prequeue) =3D=3D 0)
 		return false;
=20
+	skb_dst_force(skb);
 	__skb_queue_tail(&tp->ucopy.prequeue, skb);
 	tp->ucopy.memory +=3D skb->truesize;
 	if (tp->ucopy.memory > sk->sk_rcvbuf) {
--=20
1.8.1

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Fri__26_Apr_2013_13_38_29_+1000_qPRyoi4BqSgrPpY.
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRefa1AAoJEECxmPOUX5FEwaUP/0VVnEUforo0PP9HDKc43k2T
ERTA+v5s8a2P65v0I5119QPiqx/8sy3CqW0+cOVGc8pmvhguTGLFJpAMZPX4tCfo
/DX2gmNRRkFJxNrhPevMuSeK+KNyFf+4CpfLaoz5Xp2D10j3/C2ksn48iNG25piy
gs2aXicTWYy09iPy8F6AK6PR3dWNk1VTtSJ4sc2hYMiDOc2w1HJt9zLLcX+X/FAd
i+SYqF1mIQoiGL3NCZobG7y23chb0otR82a7jBoet3iHYFWVusbr9RvQqBTVTSBG
R4ZBk71zZMdhwlklAISsqQBzLToiP2GBH0H6XQSnGdhqsuTOj1VOj5NwYMrAgdg9
JrQbtwZfLg8zVMveAWr8sBt1YT3ZXztiEr3vwERCtKcgYveyAPKjd8jbVmrc2mB6
esoNRaE+EW2repeQYe1QaM0sKicq5qUPBz8T69J8VBhK7PMJUTr3Jtq2ehrqXBSY
dUrguonOZ0ff5nhhp+uiY0PvTpE54EljQI4KvBrpU6XtVTg3SgEmF9hUXNEm1dz7
H34dYtq5Iyubmo9vNDQBWP8DsWZHyD9cVrmF3R6cYDQ5oGxYGsWbDoWMPUnqk0ZD
xqF1CeMdtzjyvQpK8qNrBi2BKvV7JIXIvrQeWGpgB0k9FJEroBYTTivX0GDne8/G
VK6imZipTLJWHfjdNcTv
=llet
-----END PGP SIGNATURE-----

--Signature=_Fri__26_Apr_2013_13_38_29_+1000_qPRyoi4BqSgrPpY.--
