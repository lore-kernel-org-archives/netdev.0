From: Ross Kendall Axe <ross.axe@blueyonder.co.uk>
Subject: [PATCH] linux 2.9.10-rc1: Fix oops in unix_dgram_sendmsg when using
 SELinux and SOCK_SEQPACKET
Date: Sun, 14 Nov 2004 18:13:11 +0000
Message-ID: <4197A037.1020307@blueyonder.co.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig1A9E7CC68846B315A9689575"
Cc: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261322AbUKNSNa@vger.kernel.org>
To: netdev@oss.sgi.com
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig1A9E7CC68846B315A9689575
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

With CONFIG_SECURITY_NETWORK=y and CONFIG_SECURITY_SELINUX=y, using
SOCK_SEQPACKET unix domain sockets causes an oops in the superfluous(?)
call to security_unix_may_send in sock_dgram_sendmsg. This patch avoids
making this call for SOCK_SEQPACKET sockets.


Signed-off-by: Ross Axe <ross.axe@blueyonder.co.uk>


--- linux-2.6.10-rc1/net/unix/af_unix.c.orig	2004-11-13
21:04:53.000000000 +0000
+++ linux-2.6.10-rc1/net/unix/af_unix.c	2004-11-13 21:12:23.000000000 +0000
@@ -1354,9 +1354,11 @@ restart:
  	if (other->sk_shutdown & RCV_SHUTDOWN)
  		goto out_unlock;

-	err = security_unix_may_send(sk->sk_socket, other->sk_socket);
-	if (err)
-		goto out_unlock;
+	if (sk->sk_type != SOCK_SEQPACKET) {
+		err = security_unix_may_send(sk->sk_socket, other->sk_socket);
+		if (err)
+			goto out_unlock;
+	}

  	if (unix_peer(other) != sk &&
  	    (skb_queue_len(&other->sk_receive_queue) >


--------------enig1A9E7CC68846B315A9689575
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://enigmail.mozdev.org

iD8DBQFBl6A89bR4xmappRARAottAKCamwZt5rm2zbcOBZbZFCN1t3fvJACfUwt8
BLHOjOb6vwerfpiZgXdI8KM=
=TIn2
-----END PGP SIGNATURE-----

--------------enig1A9E7CC68846B315A9689575--
