From: "Ulrik De Bie" <ulrik.debie@newtec.be>
Subject: Fwd: tcp seq nr wrapping bug + patch
Date: Mon, 10 Mar 2003 16:16:13 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <se6cba6e.014@mailhost.newtec.be>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_D887874E.62036C27"
Return-path: <netdev-bounce@oss.sgi.com>
To: <jmorris@intercode.com.au>, <a@oo.ms>, <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--=_D887874E.62036C27
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hello,

I resend this patch which fixes a stupid mistake in the tcp sequence =
number in the 2.2 kernel.

Kind regards,
Ulrik De Bie

--=_D887874E.62036C27
Content-Type: message/rfc822

Date: Wed, 11 Sep 2002 17:36:27 +0200
From: "Ulrik De Bie" <ulrik.debie@newtec.be>
To: <alan.cox@linux.org>,<a@oo.ms>
Subject: tcp seq nr wrapping bug + patch
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

When the sequence number in a tcp session is about to wrap for packets
leaving the system, a problem arises:

When the system call writev is called, with a count of 5 for instance, and =
the
second iov entry makes the sequence number wrap, then the other 3 will be
sent in separate packets, because the comparison will be wrong.

before() fixes this problem.

Sorry that I'm sending from a windows machine at the moment, I don't have
a linux mail machine available at the very moment.

Kind regards,
Ulrik De Bie
udb@newtec.be




--- linux-2.2.21/net/ipv4/tcp.c	Wed Sep 11 11:03:10 2002
+++ linux/net/ipv4/tcp.c	Wed Sep 11 17:27:53 2002
@@ -823,7 +823,7 @@
 				 */
 				if (skb_tailroom(skb) > 0 &&
 				    (mss_now - copy) > 0 &&
-				    tp->snd_nxt < TCP_SKB_CB(skb)->end_seq)=
 {
+				    before(tp->snd_nxt , TCP_SKB_CB(skb)->e=
nd_seq)) {
 					int last_byte_was_odd =3D (copy % =
4);
=20
 					/*=20



--=_D887874E.62036C27--
