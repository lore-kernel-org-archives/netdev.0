From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] fix select() for SOCK_RAW sockets (ipv6)
Date: Tue, 7 Dec 2004 10:01:40 -0800
Message-ID: <20041207100140.781f4c00@dxpl.pdx.osdl.net>
References: <20041207045302.GA23746@linuxace.com>
	<20041207054840.GD61527@gaz.sfgoth.com>
	<20041207150834.GA75700@gaz.sfgoth.com>
	<20041208.023530.26430801.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mitch@sfgoth.com, kernel@linuxace.com, davem@davemloft.net,
        linux-net@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?ISO-8859-1?B?X19fX19fX19fX19f?=
 <yoshfuji@linux-ipv6.org>
In-Reply-To: <20041208.023530.26430801.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Probably, we need to do the same for ipv6, don't we?

diff -Nru a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
--- a/net/ipv6/af_inet6.c	2004-12-07 10:02:50 -08:00
+++ b/net/ipv6/af_inet6.c	2004-12-07 10:02:50 -08:00
@@ -513,6 +513,27 @@
 	.sendpage =	sock_no_sendpage,
 };
 
+struct proto_ops inet6_raw_ops = {
+	.family =	PF_INET6,
+	.owner =	THIS_MODULE,
+	.release =	inet6_release,
+	.bind =		inet6_bind,
+	.connect =	inet_dgram_connect,		/* ok		*/
+	.socketpair =	sock_no_socketpair,		/* a do nothing	*/
+	.accept =	sock_no_accept,			/* a do nothing	*/
+	.getname =	inet6_getname, 
+	.poll =		datagram_poll,			/* ok		*/
+	.ioctl =	inet6_ioctl,			/* must change  */
+	.listen =	sock_no_listen,			/* ok		*/
+	.shutdown =	inet_shutdown,			/* ok		*/
+	.setsockopt =	sock_common_setsockopt,		/* ok		*/
+	.getsockopt =	sock_common_getsockopt,		/* ok		*/
+	.sendmsg =	inet_sendmsg,			/* ok		*/
+	.recvmsg =	sock_common_recvmsg,		/* ok		*/
+	.mmap =		sock_no_mmap,
+	.sendpage =	sock_no_sendpage,
+};
+
 static struct net_proto_family inet6_family_ops = {
 	.family = PF_INET6,
 	.create = inet6_create,
@@ -528,7 +549,7 @@
 	.type		= SOCK_RAW,
 	.protocol	= IPPROTO_IP,	/* wild card */
 	.prot		= &rawv6_prot,
-	.ops		= &inet6_dgram_ops,
+	.ops		= &inet6_raw_ops,
 	.capability	= CAP_NET_RAW,
 	.no_check	= UDP_CSUM_DEFAULT,
 	.flags		= INET_PROTOSW_REUSE,
