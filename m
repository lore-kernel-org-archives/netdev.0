From: "David S. Miller" <davem@davemloft.net>
Subject: Re: 2.6.10-ac8 - kernel BUG at net/ipv4/tcp_output.c:922!
Date: Thu, 20 Jan 2005 14:59:54 -0800
Message-ID: <20050120145954.3c4992a5.davem@davemloft.net>
References: <41DFEDA8.7030805@wasp.net.au>
	<87hdlbpwpz.87fz0vpwpz@87ekgfpwpz.message.id>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: syrius.ml@no-log.org
In-Reply-To: <87hdlbpwpz.87fz0vpwpz@87ekgfpwpz.message.id>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 20 Jan 2005 14:16:42 +0100
syrius.ml@no-log.org wrote:

> It has been already reported on lkml by Brad Campbell (then forwarded
> here by randy)

Does this patch, recently merged upstream, fix your problem?

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/18 12:24:11-08:00 kuznet@ms2.inr.ac.ru 
#   [TCP]: Do not try to collapse multi-packet SKBs.
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/ipv4/tcp_output.c
#   2005/01/18 12:23:36-08:00 kuznet@ms2.inr.ac.ru +1 -0
#   [TCP]: Do not try to collapse multi-packet SKBs.
# 
diff -Nru a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
--- a/net/ipv4/tcp_output.c	2005-01-20 14:30:25 -08:00
+++ b/net/ipv4/tcp_output.c	2005-01-20 14:30:25 -08:00
@@ -1069,6 +1069,7 @@
 	   (skb->next != sk->sk_send_head) &&
 	   (skb->next != (struct sk_buff *)&sk->sk_write_queue) &&
 	   (skb_shinfo(skb)->nr_frags == 0 && skb_shinfo(skb->next)->nr_frags == 0) &&
+	   (tcp_skb_pcount(skb) == 1 && tcp_skb_pcount(skb->next) == 1) &&
 	   (sysctl_tcp_retrans_collapse != 0))
 		tcp_retrans_try_collapse(sk, skb, cur_mss);
 
