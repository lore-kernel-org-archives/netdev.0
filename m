From: Nivedita Singhvi <niv@us.ibm.com>
Subject: [PATCH 2.4] reference count clean up continued - IPv6
Date: Tue, 30 Mar 2004 23:00:28 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <406A6C8C.1000603@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: David Miller <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Continuing the reference count clean up, this time
in tcp_v6_rcv().  We should not be doing a sock_put()
on a socket in TIMEWAIT state.

Applies to 2.4.25+.

thanks,
Nivedita

diff -urN linux-2.4.25/net/ipv6/tcp_ipv6.c linux-2.4.25mc6/net/ipv6/tcp_ipv6.c
--- linux-2.4.25/net/ipv6/tcp_ipv6.c	2003-11-28 10:26:21.000000000 -0800
+++ linux-2.4.25mc6/net/ipv6/tcp_ipv6.c	2004-03-30 02:07:05.000000000 -0800
@@ -1647,7 +1647,7 @@
  do_time_wait:
  	if (skb->len < (th->doff<<2) || tcp_checksum_complete(skb)) {
  		TCP_INC_STATS_BH(TcpInErrs);
-		sock_put(sk);
+		tcp_tw_put((struct tcp_tw_bucket *) sk);
  		goto discard_it;
  	}
