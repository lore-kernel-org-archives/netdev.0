From: Olaf Hering <olh@suse.de>
Subject: Re: [PATCH] compat bug in sys_recvmsg, MSG_CMSG_COMPAT check missing
Date: Sun, 6 Jun 2004 00:37:23 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040605223723.GA32360@suse.de>
References: <20040605204334.GA1134@suse.de> <20040605140153.6c5945a0.davem@redhat.com> <20040605140544.0de4034d.davem@redhat.com> <jer7st7lam.fsf@sykes.suse.de> <20040605143649.3fd6c22b.davem@redhat.com> <jen03h7k45.fsf@sykes.suse.de> <20040605145333.11c80173.davem@redhat.com> <jeise57j95.fsf@sykes.suse.de> <20040605152949.785a9e41.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Andreas Schwab <schwab@suse.de>, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040605152949.785a9e41.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 On Sat, Jun 05, David S. Miller wrote:

> On Sun, 06 Jun 2004 00:05:58 +0200
> Andreas Schwab <schwab@suse.de> wrote:
>=20
> > Can you say DeMorgan?
>=20
> Sorry, thought I had put enough caffeine in my system.
> Aparently not :)

Lets agree on this version.


diff -p -purN linux-2.6.7-rc2-bk5.orig/net/appletalk/ddp.c linux-2.6.7-rc=
2-bk5/net/appletalk/ddp.c
--- linux-2.6.7-rc2-bk5.orig/net/appletalk/ddp.c	2004-06-05 09:34:47.0000=
00000 +0200
+++ linux-2.6.7-rc2-bk5/net/appletalk/ddp.c	2004-06-06 00:21:48.000000000=
 +0200
@@ -1567,7 +1567,7 @@ static int atalk_sendmsg(struct kiocb *i
 	struct atalk_route *rt;
 	int err;
=20
-	if (flags & ~MSG_DONTWAIT)
+	if (flags & ~(MSG_DONTWAIT|MSG_CMSG_COMPAT))
 		return -EINVAL;
=20
 	if (len > DDP_MAXSZ)
diff -p -purN linux-2.6.7-rc2-bk5.orig/net/ax25/af_ax25.c linux-2.6.7-rc2=
-bk5/net/ax25/af_ax25.c
--- linux-2.6.7-rc2-bk5.orig/net/ax25/af_ax25.c	2004-06-05 09:34:47.00000=
0000 +0200
+++ linux-2.6.7-rc2-bk5/net/ax25/af_ax25.c	2004-06-06 00:23:18.000000000 =
+0200
@@ -1413,9 +1413,8 @@ static int ax25_sendmsg(struct kiocb *io
 	size_t size;
 	int lv, err, addr_len =3D msg->msg_namelen;
=20
-	if (msg->msg_flags & ~(MSG_DONTWAIT|MSG_EOR)) {
+	if (msg->msg_flags & ~(MSG_DONTWAIT|MSG_EOR|MSG_CMSG_COMPAT))
 		return -EINVAL;
-	}
=20
 	lock_sock(sk);
 	ax25 =3D ax25_sk(sk);
diff -p -purN linux-2.6.7-rc2-bk5.orig/net/decnet/af_decnet.c linux-2.6.7=
-rc2-bk5/net/decnet/af_decnet.c
--- linux-2.6.7-rc2-bk5.orig/net/decnet/af_decnet.c	2004-06-05 09:34:47.0=
00000000 +0200
+++ linux-2.6.7-rc2-bk5/net/decnet/af_decnet.c	2004-06-06 00:23:01.000000=
000 +0200
@@ -1905,7 +1905,7 @@ static int dn_sendmsg(struct kiocb *iocb
 	unsigned char fctype;
 	long timeo =3D sock_sndtimeo(sk, flags & MSG_DONTWAIT);
=20
-	if (flags & ~(MSG_TRYHARD|MSG_OOB|MSG_DONTWAIT|MSG_EOR|MSG_NOSIGNAL|MSG=
_MORE))
+	if (flags & ~(MSG_TRYHARD|MSG_OOB|MSG_DONTWAIT|MSG_EOR|MSG_NOSIGNAL|MSG=
_MORE|MSG_CMSG_COMPAT))
 		return -EOPNOTSUPP;
=20
 	if (addr_len && (addr_len !=3D sizeof(struct sockaddr_dn)))
diff -p -purN linux-2.6.7-rc2-bk5.orig/net/econet/af_econet.c linux-2.6.7=
-rc2-bk5/net/econet/af_econet.c
--- linux-2.6.7-rc2-bk5.orig/net/econet/af_econet.c	2004-06-05 09:34:47.0=
00000000 +0200
+++ linux-2.6.7-rc2-bk5/net/econet/af_econet.c	2004-06-06 00:24:19.000000=
000 +0200
@@ -274,8 +274,8 @@ static int econet_sendmsg(struct kiocb *
 	 *	Check the flags.=20
 	 */
=20
-	if (msg->msg_flags&~MSG_DONTWAIT)=20
-		return(-EINVAL);
+	if (msg->msg_flags & ~(MSG_DONTWAIT|MSG_CMSG_COMPAT))=20
+		return -EINVAL;
=20
 	/*
 	 *	Get and verify the address.=20
diff -p -purN linux-2.6.7-rc2-bk5.orig/net/ipx/af_ipx.c linux-2.6.7-rc2-b=
k5/net/ipx/af_ipx.c
--- linux-2.6.7-rc2-bk5.orig/net/ipx/af_ipx.c	2004-06-05 09:34:48.0000000=
00 +0200
+++ linux-2.6.7-rc2-bk5/net/ipx/af_ipx.c	2004-06-06 00:24:54.000000000 +0=
200
@@ -1695,7 +1695,7 @@ static int ipx_sendmsg(struct kiocb *ioc
 	/* Socket gets bound below anyway */
 /*	if (sk->sk_zapped)
 		return -EIO; */	/* Socket not bound */
-	if (flags & ~MSG_DONTWAIT)
+	if (flags & ~(MSG_DONTWAIT|MSG_CMSG_COMPAT))
 		goto out;
=20
 	/* Max possible packet size limited by 16 bit pktsize in header */
diff -p -purN linux-2.6.7-rc2-bk5.orig/net/irda/af_irda.c linux-2.6.7-rc2=
-bk5/net/irda/af_irda.c
--- linux-2.6.7-rc2-bk5.orig/net/irda/af_irda.c	2004-06-05 09:34:48.00000=
0000 +0200
+++ linux-2.6.7-rc2-bk5/net/irda/af_irda.c	2004-06-06 00:27:55.000000000 =
+0200
@@ -1269,7 +1269,7 @@ static int irda_sendmsg(struct kiocb *io
 	IRDA_DEBUG(4, "%s(), len=3D%d\n", __FUNCTION__, len);
=20
 	/* Note : socket.c set MSG_EOR on SEQPACKET sockets */
-	if (msg->msg_flags & ~(MSG_DONTWAIT | MSG_EOR))
+	if (msg->msg_flags & ~(MSG_DONTWAIT|MSG_EOR|MSG_CMSG_COMPAT))
 		return -EINVAL;
=20
 	if (sk->sk_shutdown & SEND_SHUTDOWN) {
@@ -1521,7 +1521,7 @@ static int irda_sendmsg_dgram(struct kio
=20
 	IRDA_DEBUG(4, "%s(), len=3D%d\n", __FUNCTION__, len);
=20
-	if (msg->msg_flags & ~MSG_DONTWAIT)
+	if (msg->msg_flags & ~(MSG_DONTWAIT|MSG_CMSG_COMPAT))
 		return -EINVAL;
=20
 	if (sk->sk_shutdown & SEND_SHUTDOWN) {
@@ -1593,7 +1593,7 @@ static int irda_sendmsg_ultra(struct kio
=20
 	IRDA_DEBUG(4, "%s(), len=3D%d\n", __FUNCTION__, len);
=20
-	if (msg->msg_flags & ~MSG_DONTWAIT)
+	if (msg->msg_flags & ~(MSG_DONTWAIT|MSG_CMSG_COMPAT))
 		return -EINVAL;
=20
 	if (sk->sk_shutdown & SEND_SHUTDOWN) {
diff -p -purN linux-2.6.7-rc2-bk5.orig/net/key/af_key.c linux-2.6.7-rc2-b=
k5/net/key/af_key.c
--- linux-2.6.7-rc2-bk5.orig/net/key/af_key.c	2004-06-05 09:31:46.0000000=
00 +0200
+++ linux-2.6.7-rc2-bk5/net/key/af_key.c	2004-06-06 00:28:49.000000000 +0=
200
@@ -2726,7 +2726,7 @@ static int pfkey_recvmsg(struct kiocb *k
 	int copied, err;
=20
 	err =3D -EINVAL;
-	if (flags & ~(MSG_PEEK|MSG_DONTWAIT|MSG_TRUNC))
+	if (flags & ~(MSG_PEEK|MSG_DONTWAIT|MSG_TRUNC|MSG_CMSG_COMPAT))
 		goto out;
=20
 	msg->msg_namelen =3D 0;
diff -p -purN linux-2.6.7-rc2-bk5.orig/net/netrom/af_netrom.c linux-2.6.7=
-rc2-bk5/net/netrom/af_netrom.c
--- linux-2.6.7-rc2-bk5.orig/net/netrom/af_netrom.c	2004-06-05 09:34:48.0=
00000000 +0200
+++ linux-2.6.7-rc2-bk5/net/netrom/af_netrom.c	2004-06-06 00:29:00.000000=
000 +0200
@@ -1021,7 +1021,7 @@ static int nr_sendmsg(struct kiocb *iocb
 	unsigned char *asmptr;
 	int size;
=20
-	if (msg->msg_flags & ~(MSG_DONTWAIT|MSG_EOR))
+	if (msg->msg_flags & ~(MSG_DONTWAIT|MSG_EOR|MSG_CMSG_COMPAT))
 		return -EINVAL;
=20
 	lock_sock(sk);
diff -p -purN linux-2.6.7-rc2-bk5.orig/net/packet/af_packet.c linux-2.6.7=
-rc2-bk5/net/packet/af_packet.c
--- linux-2.6.7-rc2-bk5.orig/net/packet/af_packet.c	2004-06-05 09:34:48.0=
00000000 +0200
+++ linux-2.6.7-rc2-bk5/net/packet/af_packet.c	2004-06-05 22:32:16.000000=
000 +0200
@@ -1037,7 +1037,7 @@ static int packet_recvmsg(struct kiocb *
 	int copied, err;
=20
 	err =3D -EINVAL;
-	if (flags & ~(MSG_PEEK|MSG_DONTWAIT|MSG_TRUNC))
+	if (flags & ~(MSG_PEEK|MSG_DONTWAIT|MSG_TRUNC|MSG_CMSG_COMPAT))
 		goto out;
=20
 #if 0
diff -p -purN linux-2.6.7-rc2-bk5.orig/net/rose/af_rose.c linux-2.6.7-rc2=
-bk5/net/rose/af_rose.c
--- linux-2.6.7-rc2-bk5.orig/net/rose/af_rose.c	2004-06-05 09:34:48.00000=
0000 +0200
+++ linux-2.6.7-rc2-bk5/net/rose/af_rose.c	2004-06-06 00:29:29.000000000 =
+0200
@@ -1021,7 +1021,7 @@ static int rose_sendmsg(struct kiocb *io
 	unsigned char *asmptr;
 	int n, size, qbit =3D 0;
=20
-	if (msg->msg_flags & ~(MSG_DONTWAIT|MSG_EOR))
+	if (msg->msg_flags & ~(MSG_DONTWAIT|MSG_EOR|MSG_CMSG_COMPAT))
 		return -EINVAL;
=20
 	if (sk->sk_zapped)
diff -p -purN linux-2.6.7-rc2-bk5.orig/net/wanrouter/af_wanpipe.c linux-2=
.6.7-rc2-bk5/net/wanrouter/af_wanpipe.c
--- linux-2.6.7-rc2-bk5.orig/net/wanrouter/af_wanpipe.c	2004-06-05 09:34:=
48.000000000 +0200
+++ linux-2.6.7-rc2-bk5/net/wanrouter/af_wanpipe.c	2004-06-06 00:29:51.00=
0000000 +0200
@@ -552,7 +552,7 @@ static int wanpipe_sendmsg(struct kiocb=20
 	if (sk->sk_state !=3D WANSOCK_CONNECTED)
 		return -ENOTCONN;=09
=20
-	if (msg->msg_flags&~MSG_DONTWAIT)=20
+	if (msg->msg_flags & ~(MSG_DONTWAIT|MSG_CMSG_COMPAT))=20
 		return(-EINVAL);
=20
 	/* it was <=3D, now one can send
diff -p -purN linux-2.6.7-rc2-bk5.orig/net/x25/af_x25.c linux-2.6.7-rc2-b=
k5/net/x25/af_x25.c
--- linux-2.6.7-rc2-bk5.orig/net/x25/af_x25.c	2004-06-05 09:34:48.0000000=
00 +0200
+++ linux-2.6.7-rc2-bk5/net/x25/af_x25.c	2004-06-06 00:30:20.000000000 +0=
200
@@ -922,7 +922,7 @@ static int x25_sendmsg(struct kiocb *ioc
 	size_t size;
 	int qbit =3D 0, rc =3D -EINVAL;
=20
-	if (msg->msg_flags & ~(MSG_DONTWAIT | MSG_OOB | MSG_EOR))
+	if (msg->msg_flags & ~(MSG_DONTWAIT|MSG_OOB|MSG_EOR|MSG_CMSG_COMPAT))
 		goto out;
=20
 	/* we currently don't support segmented records at the user interface *=
/

--=20
USB is for mice, FireWire is for men!

sUse lINUX ag, n=C3=9CRNBERG
