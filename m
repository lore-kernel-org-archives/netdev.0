From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] add receive DRS info
Date: Mon, 7 Jun 2004 10:07:44 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040607100744.1b67baa2@dell_ss3.pdx.osdl.net>
References: <20040604153749.5d8a13b9@dell_ss3.pdx.osdl.net>
	<20040604205749.11725598.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040604205749.11725598.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Add receiver feedback information to the tcp_info structure to allow
looking at receive dynamic right sizing with 'ss' command.

This increases the size of the structure, but since both getsockopt() and netlink
interface pass length in request; it retains compatibility with older versions.

diff -Nru a/include/linux/tcp.h b/include/linux/tcp.h
--- a/include/linux/tcp.h	2004-06-07 10:07:25 -07:00
+++ b/include/linux/tcp.h	2004-06-07 10:07:25 -07:00
@@ -183,6 +183,9 @@
 	__u32	tcpi_snd_cwnd;
 	__u32	tcpi_advmss;
 	__u32	tcpi_reordering;
+
+	__u32	tcpi_rcv_rtt;
+	__u32	tcpi_rcv_space;
 };
 
 #ifdef __KERNEL__
diff -Nru a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
--- a/net/ipv4/tcp_diag.c	2004-06-07 10:07:25 -07:00
+++ b/net/ipv4/tcp_diag.c	2004-06-07 10:07:25 -07:00
@@ -91,6 +91,9 @@
 	info->tcpi_snd_cwnd = tp->snd_cwnd;
 	info->tcpi_advmss = tp->advmss;
 	info->tcpi_reordering = tp->reordering;
+
+	info->tcpi_rcv_rtt = ((1000000*tp->rcv_rtt_est.rtt)/HZ)>>3;
+	info->tcpi_rcv_space = tp->rcvq_space.space;
 }
 
 static int tcpdiag_fill(struct sk_buff *skb, struct sock *sk,
