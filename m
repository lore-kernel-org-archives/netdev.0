From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the vfs tree
Date: Fri, 13 Mar 2015 13:15:43 +1100
Message-ID: <20150313131543.7c050492@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/gq5ucSd4VE9yMwX2d+==V2J"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Christoph Hellwig <hch@lst.de>,
	Ying Xue <ying.xue@windriver.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/gq5ucSd4VE9yMwX2d+==V2J
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/socket.c between commits 005139a14660 ("fs: remove ki_nbytes") and
e9eab93cc2dc ("fs: don't allow to complete sync iocbs through
aio_complete") from the vfs tree and commit 1b784140474e ("net: Remove
iocb argument from sendmsg and recvmsg") from the net-next tree.

I fixed it up (mainly using the net-next version - see below) and can
carry the fix as necessary (no action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/socket.c
index f6c519d7b3ba,95d3085cb477..000000000000
--- a/net/socket.c
+++ b/net/socket.c
@@@ -855,11 -807,10 +807,10 @@@ static ssize_t sock_read_iter(struct ki
  	if (iocb->ki_pos !=3D 0)
  		return -ESPIPE;
 =20
 -	if (iocb->ki_nbytes =3D=3D 0)	/* Match SYS5 behaviour */
 +	if (!iov_iter_count(to))	/* Match SYS5 behaviour */
  		return 0;
 =20
- 	res =3D __sock_recvmsg(iocb, sock, &msg,
- 			     iov_iter_count(to), msg.msg_flags);
 -	res =3D sock_recvmsg(sock, &msg, iocb->ki_nbytes, msg.msg_flags);
++	res =3D sock_recvmsg(sock, &msg, iov_iter_count(to), msg.msg_flags);
  	*to =3D msg.msg_iter;
  	return res;
  }
@@@ -880,7 -831,7 +831,7 @@@ static ssize_t sock_write_iter(struct k
  	if (sock->type =3D=3D SOCK_SEQPACKET)
  		msg.msg_flags |=3D MSG_EOR;
 =20
- 	res =3D __sock_sendmsg(iocb, sock, &msg, iov_iter_count(from));
 -	res =3D sock_sendmsg(sock, &msg, iocb->ki_nbytes);
++	res =3D sock_sendmsg(sock, &msg, iov_iter_count(from));
  	*from =3D msg.msg_iter;
  	return res;
  }

--Sig_/gq5ucSd4VE9yMwX2d+==V2J
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVAkhUAAoJEMDTa8Ir7ZwVG5EP/1vqUfrhDlfVPB4neBvGHVrI
ilRXWeza00D+cxKXrzIHgzlJWpnEHzMSM2kSlKTNbggZmWUdG4NPh8ie/aElkoN0
gwmYkzrJKeePlNtZGwJUkdWqdXXw+HfB5PFIg2ew1Yjc7PbJ6CAu+4OdZz05aFHx
gIddKx1FI1zlhITz7SGbbkuVPNNNJ1A2s5Rp+VEHJZROIYam3nCen51TgSUJZ+uV
QiSzWHAgSgd1d/nHpI45dfsOUBAEIYkECWYp5Vs4vVmCcEfGDx7wHNX+2Biyt9gx
Tfh17UfaJcmu1RFUQPK/zPREgokdmHEepOMrkTnYEIxbCjZn3a6TBP2to/KedOY0
1GxlIMkFoPum6Bhgigh8puBK5lH/SgkYwy+2UR7YQNyuRobuv7/y0WLCDpYb5EfT
OtfY2T64APbWFZ67vKrtbu2i+SxBuCjY/QbGiO8NqrOPktSoZIE58UR1B4L0Jsh4
Ltl1eYeW6kBD5s+uDQgVf1d6b52R5AcyvU7fsQm3EeXAGhTfMVb36et67/r6fF8D
hBorWrO2cZXBX42zKYyrlS4F5Vsg1aPoM1jQSBCqsQpeXkcL+CJMRkMG1N2Dq6eo
rbBIdpxWImpPz/NgoNUgX98Q3OZIfB1e5H+yVGQikOauosyTxF2zitlkB2Wih4Jh
YXYIstnK9pYKap7Fhf6v
=zMg+
-----END PGP SIGNATURE-----

--Sig_/gq5ucSd4VE9yMwX2d+==V2J--
