From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Fri, 14 Sep 2012 11:17:57 +1000
Message-ID: <20120914111757.83aee928b17b60bbbc09f4d7@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__14_Sep_2012_11_17_57_+1000_xSdNcQbr+ugS0EU3"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__14_Sep_2012_11_17_57_+1000_xSdNcQbr+ugS0EU3
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/netfilter/xt_LOG.c between commit 0626af313957 ("netfilter: take care
of timewait sockets") from the net tree and commit 8c6e2a941ae7 ("userns:
Convert xt_LOG to print socket kuids and kgids as uids and gids") from
the net-next tree.

I fixed it up (I think - see below) and can carry the fix as necessary
(no action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/netfilter/xt_LOG.c
index 91e9af4,02a2bf4..0000000
--- a/net/netfilter/xt_LOG.c
+++ b/net/netfilter/xt_LOG.c
@@@ -145,19 -145,6 +145,21 @@@ static int dump_tcp_header(struct sbuf
  	return 0;
  }
 =20
 +static void dump_sk_uid_gid(struct sbuff *m, struct sock *sk)
 +{
 +	if (!sk || sk->sk_state =3D=3D TCP_TIME_WAIT)
 +		return;
 +
 +	read_lock_bh(&sk->sk_callback_lock);
 +	if (sk->sk_socket && sk->sk_socket->file) {
++		const struct cred *cred =3D sk->sk_socket->file->f_cred;
 +		sb_add(m, "UID=3D%u GID=3D%u ",
- 			sk->sk_socket->file->f_cred->fsuid,
- 			sk->sk_socket->file->f_cred->fsgid);
++			from_kuid_munged(&init_user_ns, cred->fsuid),
++			from_kgid_munged(&init_user_ns, cred->fsgid));
++	}
 +	read_unlock_bh(&sk->sk_callback_lock);
 +}
 +
  /* One level of recursion won't kill us */
  static void dump_ipv4_packet(struct sbuff *m,
  			const struct nf_loginfo *info,

--Signature=_Fri__14_Sep_2012_11_17_57_+1000_xSdNcQbr+ugS0EU3
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQUoXFAAoJEECxmPOUX5FE/SUQAJn3bmHOSOWg/4w57bS8toxv
njVa6n9BW+vugSA0f+AloczncYGw7UOBVTNJb/UR/STKO3Q9nSTw0TLAVpsltDOu
eDEyqJzc8JIIJOz9DNSMg8QOKMGy1Rif0XOiz+pds2EUKa1O+JaXVZby4bTB+mae
/fDbNLyzDxVZPSYYihbhSmwhtdWSyvA5lDg2MCilA/CznXgyu0UQ01bEVVRXVAly
Yft3hki6qBKxSoYFYCFNd4NAhyh9NhfA7yYV/qFhEB4kUq/OPW3CqLr2GEgnEfYt
A8qeaDJZUCi5d8nzH3Mnx0vM8o4+7iqDRxd5iyOSTlgUruP/FactzmAv91DqwueQ
kQrneQ9/qX5T1g67oCcOAfdmOLg0uzkR/AQYNHux5CIf8gukV7wobrxI8sqh95kW
gwld3SLnZhYsPgrjfcKL7NGDLG1nfTEKd5iej3hYHfZnqCsD5nsPqkuSZDOi5aYG
ynHRBQBSdcSSg/yxL3197nwnSl5Kc3/+SQLWYrIavXDMT8bLquDWZEZGoMaqbvwJ
SqjRaIXPPdqHRNnGnsvRBukaIz+U4aQGMeR10Hm/OAOcXarsKPSTW5t0CusKLtan
Xq0MM6IeGwcZnC6R8P01/SvJuKFkuQV9n0OOQJtgq0nM4z8HGVJRLCXcwCYrZ4Cc
SxYquPR3GciyJCV/Wk/3
=4M74
-----END PGP SIGNATURE-----

--Signature=_Fri__14_Sep_2012_11_17_57_+1000_xSdNcQbr+ugS0EU3--
